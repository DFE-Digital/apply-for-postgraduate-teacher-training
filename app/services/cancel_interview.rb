class CancelInterview
  attr_reader :auth, :application_choice, :interview, :cancellation_reason

  def initialize(
    actor:,
    application_choice:,
    interview:,
    cancellation_reason:
  )
    @auth = ProviderAuthorisation.new(actor: actor)
    @application_choice = application_choice
    @interview = interview
    @cancellation_reason = cancellation_reason
  end

  def save!
    auth.assert_can_make_decisions!(
      application_choice: application_choice,
      course_option_id: application_choice.offered_option.id,
    )

    if ApplicationStateChange.new(application_choice).can_cancel_interview?
      ActiveRecord::Base.transaction do
        interview.update!(cancellation_reason: cancellation_reason,
                          cancelled_at: Time.zone.now)

        ApplicationStateChange.new(application_choice).cancel_interview!
      end
    else
      raise "Interview cannot be cancelled when the application_choice is in #{application_choice.status} state"
    end
  end
end
