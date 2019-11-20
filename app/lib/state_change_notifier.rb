class StateChangeNotifier
  def self.call(event, candidate: nil, application_choice: nil)
    helpers = Rails.application.routes.url_helpers

    if application_choice
      provider_name = application_choice.course.provider.name
      applicant = application_choice.application_form.first_name
      application_form_id = application_choice.application_form.id
    end

    case event
    when :magic_link_sign_up
      text = "New sign-up [candidate_id: #{candidate.id}]"
      url = helpers.support_interface_applications_url
    when :submit_application
      text = "#{applicant} has just submitted an application"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :send_application_to_provider
      text = "#{applicant}'s application is ready to be reviewed by #{provider_name}"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :make_an_offer
      text = "#{provider_name} has just made an offer to #{applicant}'s application"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :reject_application
      text = "#{provider_name} has just rejected #{applicant}'s application"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :reject_application_by_default
      text = "#{applicant}'s application has just been rejected by default"
      url = helpers.support_interface_application_form_url(application_form_id)
    else
      raise 'StateChangeNotifier: unsupported state transition event'
    end
    SlackNotificationWorker.perform_async(text, url)
  end
end
