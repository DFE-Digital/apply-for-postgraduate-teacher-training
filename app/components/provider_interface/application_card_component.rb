module ProviderInterface
  class ApplicationCardComponent < ViewComponent::Base
    include ViewHelper

    attr_accessor :accredited_provider, :application_choice, :application_choice_path,
                  :candidate_name, :course_name_and_code, :course_provider_name, :changed_at,
                  :most_recent_note, :site_name_and_code, :sort_by

    def initialize(application_choice:, sort_by: nil)
      @accredited_provider = application_choice.accredited_provider
      @application_choice = application_choice
      @candidate_name = application_choice.application_form.full_name
      @course_name_and_code = application_choice.offered_course.name_and_code
      @course_provider_name = application_choice.offered_course.provider.name
      @changed_at = application_choice.updated_at.to_s(:govuk_date_and_time)
      @site_name_and_code = application_choice.site.name_and_code
      @most_recent_note = application_choice.notes.order('created_at DESC').first
      @sort_by = sort_by
    end

    def contextual_date
      return changed_at_date unless sort_by && sort_by == 'Days left to respond'
      return changed_at_date unless reject_by_default_in_future?

      return '1 day to respond' if days_to_respond == 1
      return 'Less than 1 day to respond' if days_to_respond < 1

      "#{days_to_respond} days to respond"
    end

  private

    def changed_at_date
      "Changed #{changed_at}"
    end

    def reject_by_default_in_future?
      application_choice.reject_by_default_at.present? &&
        application_choice.reject_by_default_at > Time.current
    end

    def days_to_respond
      @days_to_respond ||= (application_choice.reject_by_default_at.to_date - Date.current).to_i
    end
  end
end
