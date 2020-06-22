class ApplicationStateChange
  include Workflow

  STATES_NOT_VISIBLE_TO_PROVIDER = %i[unsubmitted awaiting_references application_complete cancelled].freeze
  ACCEPTED_STATES = %i[pending_conditions conditions_not_met recruited enrolled].freeze
  OFFERED_STATES = (ACCEPTED_STATES + %i[declined offer]).freeze

  attr_reader :application_choice

  def initialize(application_choice)
    @application_choice = application_choice
  end

  # When updating states, don't forget to run:
  #
  #   bundle exec rake generate_state_diagram
  #
  workflow do
    state :withdrawn

    state :unsubmitted do
      event :submit, transitions_to: :awaiting_references
      event :send_to_provider, transitions_to: :awaiting_provider_decision
    end

    state :awaiting_references do
      event :references_complete, transitions_to: :application_complete
      event :cancel, transitions_to: :cancelled
    end

    state :application_complete do
      event :send_to_provider, transitions_to: :awaiting_provider_decision
      event :cancel, transitions_to: :cancelled
    end

    state :awaiting_provider_decision do
      event :make_offer, transitions_to: :offer
      event :reject, transitions_to: :rejected
      event :reject_by_default, transitions_to: :rejected
      event :withdraw, transitions_to: :withdrawn
    end

    state :rejected do
      event :make_offer, transitions_to: :offer
    end

    state :offer do
      event :make_offer, transitions_to: :offer
      event :reject, transitions_to: :rejected
      event :accept, transitions_to: :pending_conditions
      event :decline, transitions_to: :declined
      event :decline_by_default, transitions_to: :declined
    end

    state :declined

    state :pending_conditions do
      event :confirm_conditions_met, transitions_to: :recruited
      event :conditions_not_met, transitions_to: :conditions_not_met
      event :withdraw, transitions_to: :withdrawn
    end

    state :conditions_not_met

    state :recruited do
      event :confirm_enrolment, transitions_to: :enrolled
      event :withdraw, transitions_to: :withdrawn
    end

    state :enrolled

    state :cancelled
  end

  UNSUCCESSFUL_END_STATES = %w[withdrawn cancelled rejected declined conditions_not_met].freeze

  def load_workflow_state
    application_choice.status
  end

  def persist_workflow_state(new_state)
    application_choice.update!(status: new_state)
  end

  def self.valid_states
    workflow_spec.states.keys
  end

  def self.states_visible_to_provider
    valid_states - STATES_NOT_VISIBLE_TO_PROVIDER
  end

  def self.i18n_namespace
    ''
  end

  def self.state_count(state_name)
    ApplicationChoice.where(status: state_name).count
  end
end
