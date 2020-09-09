module ProviderInterface
  class ApplicationStatusTagComponent < ViewComponent::Base
    validates :application_choice, presence: true
    delegate :status, to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def text
      I18n.t!("provider_application_states.#{status}")
    end

    def type
      case status
      when 'unsubmitted', 'application_complete', 'cancelled', 'awaiting_references'
        # will never be visible to the provider
      when 'awaiting_provider_decision'
        :purple
      when 'offer'
        :turquoise
      when 'pending_conditions'
        :blue
      when 'recruited'
        :green
      when 'rejected', 'conditions_not_met', 'offer_withdrawn', 'application_not_sent'
        :orange
      when 'declined', 'withdrawn'
        :red
      when 'offer_deferred'
        :yellow
      else
        raise "You need to define a colour for the #{status} state"
      end
    end

  private

    attr_reader :application_choice
  end
end
