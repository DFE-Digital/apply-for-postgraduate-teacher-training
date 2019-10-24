class SubmitApplication
  attr_reader :application_form, :application_choices, :candidate_email

  def initialize(application_form)
    @application_form = application_form
    @application_choices = application_form.application_choices
    @candidate_email = application_form.candidate.email_address
  end

  def call
    submit_application

    application_form.update!(support_reference: GenerateSupportRef.call,
                             submitted_at: Time.now)

    CandidateMailer
      .submit_application_email(to: candidate_email, support_reference: application_form.support_reference)
      .deliver_now
  end

private

  def submit_application
    ActiveRecord::Base.transaction do
      application_choices.each do |application_choice|
        ApplicationStateChange.new(application_choice).submit!
      end
    end
  end
end
