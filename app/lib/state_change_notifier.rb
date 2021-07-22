class StateChangeNotifier
  APPLICATION_OUTCOME_EVENTS = %i[declined declined_by_default withdrawn rejected rejected_by_default recruited withdrawn_at_candidates_request].freeze

  attr_reader :application_choice, :event

  def initialize(event, application_choice)
    @event = event
    @application_choice = application_choice
  end

  def application_outcome_notification
    candidate_name = application_choice.application_form.first_name

    other_applications = application_choice.self_and_siblings.where.not(id: application_choice.id)
    grouped_applications = group_by_status(other_applications)

    providers = [application_choice.course.provider.name] + providers_for(event, grouped_applications)

    other_events = APPLICATION_OUTCOME_EVENTS - [event]
    other_applications_outcome = other_events.map { |e| text_for(grouped_applications, e) }.compact.to_sentence

    message = I18n.t("slack_notifications.#{event}.message.primary", applicant: candidate_name, providers: providers.to_sentence, count: providers.count)
    message << ". #{candidate_name} previously #{other_applications_outcome}." if other_applications_outcome.present?

    url = StateChangeNotifier.helpers.support_interface_application_form_url(application_choice.application_form)

    StateChangeNotifier.send(message, url)
  end

  def self.sign_up(candidate)
    candidate_number = Candidate.where(hide_in_reporting: false).count

    return unless (candidate_number % 100).zero?

    candidate_number_is_significant = (candidate_number % 500).zero?
    ordinal_number = "#{ActiveSupport::NumberHelper.number_to_delimited(candidate_number)}#{candidate_number.ordinal}"
    milestone = candidate_number_is_significant ? 'major' : 'minor'
    text = I18n.t("slack_notifications.sign_up.#{milestone}_milestone", candidate_number: ordinal_number)
    url = helpers.support_interface_candidate_url(candidate)

    send(text, url)
  end

  def self.call(event, application_choice: nil)
    return new(event, application_choice).application_outcome_notification if APPLICATION_OUTCOME_EVENTS.include?(event)

    provider_name = application_choice.course.provider.name
    candidate_name = application_choice.application_form.first_name
    application_form = application_choice.application_form

    case event
    when :change_an_offer
      text = ":love_letter: #{provider_name} has changed an offer for #{candidate_name}’s application"
    when :defer_offer
      text = ":double_vertical_bar: #{provider_name} has deferred #{candidate_name}’s offer"
    else
      raise 'StateChangeNotifier: unsupported state transition event'
    end

    url = helpers.support_interface_application_form_url(application_form)

    send(text, url)
  end

  def self.send(text, url)
    if RequestStore.store[:disable_state_change_notifications]
      Rails.logger.info "Sending Slack messages disabled (message: `#{text}`)"
      return
    end

    SlackNotificationWorker.perform_async(text, url)
  end

  def self.helpers
    Rails.application.routes.url_helpers
  end

  def self.disable_notifications
    # support nesting these blocks
    prior_state = RequestStore.store[:disable_state_change_notifications].presence || false

    RequestStore.store[:disable_state_change_notifications] = true
    yield
    RequestStore.store[:disable_state_change_notifications] = prior_state
  end

private

  def providers_for(event, applications)
    return [] if event == :recruited

    applications[event].map(&:provider).map(&:name)
  end

  def text_for(applications, event)
    providers = providers_for(event, applications)
    return if providers.none?

    I18n.t("slack_notifications.#{event}.message.other_applications", providers: providers.to_sentence, count: providers.count)
  end

  def group_by_status(applications)
    applications.inject(APPLICATION_OUTCOME_EVENTS.index_with { |_| [] }) do |grouped, application|
      status = :rejected_by_default if application.rejected? && application.rejected_by_default?
      status = :declined_by_default if application.declined? && application.declined_by_default?
      status = :withdrawn_at_candidates_request if application.withdrawn_at_candidates_request?
      status ||= application.status.to_sym

      grouped[status] << application if grouped.key?(status)
      grouped
    end
  end
end
