class ReceiveReference
  attr_reader :reference, :feedback

  def initialize(reference:, feedback:)
    @reference = reference
    @feedback = feedback
  end

  def save!
    ActiveRecord::Base.transaction do
      @reference.update!(feedback: @feedback, feedback_status: 'feedback_provided')
      progress_application_if_enough_references_have_been_submitted
    end
  end

private

  def progress_application_if_enough_references_have_been_submitted
    application_form = reference.application_form

    return unless application_form.application_references_complete?

    application_form.application_choices.each do |application_choice|
      ApplicationStateChange.new(application_choice).references_complete!
    end

    SendApplicationsToProvider.new.call
  end
end
