module ProviderInterface
  class OfferSummaryListComponent < ActionView::Component::Base
    include ViewHelper
    attr_reader :application_choice, :header, :options

    def initialize(application_choice:, header: 'Your offer', options: {})
      @application_choice = application_choice
      @header = header
      @course_option_id = options[:new_course_option_id]
      @entry = options[:entry]
    end

    def rows
      [
        {
          key: 'Candidate name',
          value: application_choice.application_form.full_name,
        },
        {
          key: 'Provider',
          value: course_option.course.provider.name,
          change_path: change_path(:provider), action: 'training provider'
        },
        {
          key: 'Course',
          value: course_option.course.name_and_code,
          change_path: change_path(:course), action: 'course'
        },
        {
          key: 'Location',
          value: course_option.site.name_and_address,
          change_path: change_path(:course_option), action: 'location'
        },
      ]
    end

    def paths
      Rails.application.routes.url_helpers
    end

    # paths produced preserve the current (unsaved) provider/course/option selection
    def change_path(target)
      if new_course_option
        case target
        when :provider
          paths.provider_interface_application_choice_change_offer_edit_provider_path(application_choice.id, current_selection_params) if show_provider_link?
        when :course
          paths.provider_interface_application_choice_change_offer_edit_course_path(application_choice.id, current_selection_params) if show_course_link?
        when :course_option
          paths.provider_interface_application_choice_change_offer_edit_course_option_path(application_choice.id, current_selection_params)
        end
      end
    end

    def show_provider_link?
      @entry == 'provider'
    end

    def show_course_link?
      @entry != 'course_option'
    end

    def new_course_option
      if @course_option_id
        @new_course_option ||= CourseOption.find(@course_option_id)
        @new_course_option if @course_option_id != application_choice.offered_option.id
      end
    end

    def course_option
      new_course_option || application_choice.offered_option
    end

    def current_selection_params
      {
        provider_interface_change_offer_form: {
          provider_id: course_option.course.provider.id,
          course_id: course_option.course.id,
          course_option_id: course_option.id,
        },
        entry: @entry,
      }
    end
  end
end
