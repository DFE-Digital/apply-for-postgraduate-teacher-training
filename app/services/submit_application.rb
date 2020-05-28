class SubmitApplication
  attr_reader :application_form, :application_choices

  REFEREE_BOT_EMAIL_ADDRESSES = ['refbot1@example.com', 'refbot2@example.com'].freeze

  def initialize(application_form)
    @application_form = application_form
    @application_choices = application_form.application_choices
  end

  def call
    ActiveRecord::Base.transaction do
      application_form.update!(
        submitted_at: Time.zone.now,
        edit_by: edit_by_time,
      )

      application_choices.each do |application_choice|
        if ready_to_be_sent_to_provider?
          SendApplicationToProvider.new(application_choice: application_choice).call
        else
          ApplicationStateChange.new(application_choice).submit!
        end
      end
    end

    if ready_to_be_sent_to_provider?
      CandidateMailer.application_sent_to_provider(@application_form).deliver_later
    else
      CandidateMailer.application_submitted(application_form).deliver_later
    end

    send_reference_request_email_to_referees(application_form)
    StateChangeNotifier.call(:submit_application, application_form: application_form)
    auto_approve_references_in_sandbox(application_form)
  end

private

  def send_reference_request_email_to_referees(application_form)
    application_form.application_references.not_requested_yet.includes(:application_form).each do |reference|
      CandidateInterface::RequestReference.call(reference)
    end
  end

  def auto_approve_references_in_sandbox(application_form)
    application_form.application_references.includes(:application_form).each do |reference|
      auto_approve_reference(reference) if HostingEnvironment.sandbox_mode? && email_address_is_a_bot?(reference)
    end
  end

  def auto_approve_reference(reference)
    reference.update!(
      relationship_correction: '',
      safeguarding_concerns: '',
      feedback: I18n.t('new_referee_request.auto_approve_feedback'),
    )

    SubmitReference.new(
      reference: reference,
    ).save!
  end

  def email_address_is_a_bot?(reference)
    REFEREE_BOT_EMAIL_ADDRESSES.include?(reference.email_address)
  end

  def ready_to_be_sent_to_provider?
    !application_form.can_edit_after_submission? && enough_references_have_been_provided?
  end

  def enough_references_have_been_provided?
    application_form
      .application_references
      .feedback_provided
      .uniq
      .count >= ApplicationForm::MINIMUM_COMPLETE_REFERENCES
  end

  def edit_by_time
    if HostingEnvironment.sandbox_mode?
      Time.zone.now
    elsif application_form.can_edit_after_submission?
      TimeLimitConfig.edit_by.to_days.after(Time.zone.now).end_of_day
    else
      Time.zone.now
    end
  end
end
