module SupportInterface
  class ApplicationStatusTagComponent < ViewComponent::Base
    def initialize(status:)
      @status = status
    end

    def text
      I18n.t!("application_states.#{@status}.name")
    end

    def type
      case @status
      when 'unsubmitted'
        :grey
      when 'application_complete', 'awaiting_references', 'awaiting_provider_decision', 'offer_deferred'
        :yellow
      when 'offer'
        :turquoise
      when 'pending_conditions'
        :blue
      when 'recruited'
        :green
      when 'conditions_not_met', 'declined', 'rejected', 'offer_withdrawn', 'withdrawn', 'cancelled', 'application_not_sent'
        :red
      else
        raise "You need to define a colour for the #{@status} state"
      end
    end
  end
end
