module ProviderInterface
  class OfferSummaryComponent < ViewComponent::Base
    include ViewHelper

    attr_accessor :application_choice, :course, :course_option, :conditions, :available_providers, :available_courses, :available_course_options

    def initialize(application_choice:, course:, course_option:, conditions:, available_providers: [], available_courses: [], available_course_options: [])
      @application_choice = application_choice
      @course_option = course_option
      @conditions = conditions
      @available_providers = available_providers
      @available_courses = available_courses
      @available_course_options = available_course_options
      @course = course
    end

    def rows
      [
        { key: 'Provider',
          value: course_option.provider.name_and_code,
          action: 'Change',
          change_path: change_provider_path },
        { key: 'Course',
          value: course_option.course.name_and_code,
          action: 'Change',
          change_path: change_course_path },
        { key: 'Location',
          value: course_option.site.name_and_address,
          action: 'Change',
          change_path: change_location_path },
        { key: 'Full time or part time',
          value: course_option.study_mode.humanize,
          action: 'Change',
          change_path: change_study_mode_path },
      ]
    end

    def change_provider_path
      available_providers.many? ? new_provider_interface_application_choice_offer_providers_path(application_choice) : nil
    end

    def change_course_path
      available_courses.many? ? new_provider_interface_application_choice_offer_courses_path(application_choice) : nil
    end

    def change_location_path
      available_course_options.many? ? new_provider_interface_application_choice_offer_locations_path(application_choice) : nil
    end

    def change_study_mode_path
      course.full_time_or_part_time? ? new_provider_interface_application_choice_offer_study_modes_path(application_choice) : nil
    end

    def mode
      :new
    end
  end
end
