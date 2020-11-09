class SubmitApplication
  attr_reader :application_form, :application_choices

  def initialize(application_form)
    @application_form = application_form
    @application_choices = application_form.application_choices
  end

  def call
    application_form.update!(submitted_at: Time.zone.now)

    application_choices.each do |application_choice|
      SendApplicationToProvider.call(application_choice)
    end

    if application_form.apply_2?
      CandidateMailer.application_submitted_apply_again(application_form).deliver_later
    else
      CandidateMailer.application_submitted(application_form).deliver_later
    end

      StateChangeNotifier.submit_application(application_form)
  end
end
