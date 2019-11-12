class SubmitApplication
  attr_reader :application_form, :application_choices

  def initialize(application_form)
    @application_form = application_form
    @application_choices = application_form.application_choices
  end

  def call
    submit_application

    application_form.update!(support_reference: GenerateSupportRef.call,
                             submitted_at: Time.zone.now)

    CandidateMailer.submit_application_email(application_form).deliver_now
  end

private

  def submit_application
    ActiveRecord::Base.transaction do
      application_choices.each do |application_choice|
        application_choice.edit_by = ApplicationDates.new(application_form).edit_by
        ApplicationStateChange.new(application_choice).submit!
      end
    end
  end
end
