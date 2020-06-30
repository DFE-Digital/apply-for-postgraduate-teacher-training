module SupportInterface
  class ApplicationStatusTagComponent < ViewComponent::Base
    validates :application_choice, presence: true
    delegate :status, to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def text
      I18n.t!("application_states.#{status}.name")
    end

    def type
      case status
      when 'unsubmitted'
        :grey
      when 'awaiting_references', 'awaiting_provider_decision'
        :yellow
      when 'offer'
        :turquoise
      when 'pending_conditions'
        :blue
      when 'recruited'
        :green
      when 'conditions_not_met', 'declined', 'rejected', 'withdrawn', 'cancelled'
        :red
      else
        raise "You need to define a color for the #{status} state"
      end
    end

  private

    attr_reader :application_choice
  end
end
