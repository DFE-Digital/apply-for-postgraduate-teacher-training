module ProviderInterface
  class ApplicationCardComponent < ViewComponent::Base
    include ViewHelper

    attr_accessor :accredited_provider, :application_choice, :application_choice_path,
                  :candidate_name, :course_name_and_code, :course_provider_name, :changed_at,
                  :most_recent_note, :site_name_and_code

    def initialize(application_choice:)
      @accredited_provider = application_choice.accredited_provider
      @application_choice = application_choice
      @candidate_name = application_choice.application_form.full_name
      @course_name_and_code = application_choice.offered_course.name_and_code
      @course_provider_name = application_choice.offered_course.provider.name
      @changed_at = application_choice.updated_at.to_s(:govuk_date_and_time)
      @site_name_and_code = application_choice.site.name_and_code
      @most_recent_note = application_choice.notes.order('created_at DESC').first
    end
  end
end
