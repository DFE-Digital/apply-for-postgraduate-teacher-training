module ProviderInterface
  class ApplicationTimelineComponent < ViewComponent::Base
    attr_reader :application_choice
    validates :application_choice, presence: true

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    Event = Struct.new(:title, :actor, :date)

    TITLES = {
      'awaiting_provider_decision' => 'Application submitted',
      'withdrawn' => 'Application withdrawn',
      'rejected' => 'Application rejected',
      'rejected_at_end_of_cycle' => 'Rejected at end of cycle',
      'offer_withdrawn' => 'Offer withdrawn',
      'offer' => 'Offer made',
      'pending_conditions' => 'Offer accepted',
      'declined' => 'Offer declined',
      'recruited' => 'Recruited',
      'conditions_not_met' => 'Conditions marked not met',
      'offer_deferred' => 'Offer deferred',
    }.freeze

  private

    def status_change_events
      changes = FindStatusChangeAudits.new(application_choice: application_choice).call
      changes = changes.select { |change| TITLES.key?(change.status) }
      changes.map do |change|
        Event.new(
          title_for(change),
          actor_for(change),
          change.changed_at,
        )
      end
    end

    def note_events
      if application_choice.notes.present?
        application_choice.notes.order('created_at').map do |note|
          Event.new(
            'Note added',
            provider_name(note.provider_user),
            note.created_at,
          )
        end
      else
        []
      end
    end

    def events
      (status_change_events + note_events).sort_by(&:date).reverse
    end

    def title_for(change)
      TITLES[change.status]
    end

    def actor_for(change)
      if change.user.is_a?(Candidate)
        'candidate'
      elsif change.user.is_a?(ProviderUser)
        provider_name(change.user)
      else
        'system'
      end
    end

    def provider_name(provider_user)
      # TODO: Work out how to display the provider name (it's ambiguous)
      provider_user.full_name
    end
  end
end
