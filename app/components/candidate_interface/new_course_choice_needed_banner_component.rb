module CandidateInterface
  class NewCourseChoiceNeededBannerComponent < ViewComponent::Base
    include ViewHelper

    validates :application_form, presence: true

    def initialize(application_form:)
      @application_form = application_form
    end

    def render?
      FeatureFlag.active?('replace_full_or_withdrawn_application_choices') &&
        @application_form.course_choices_that_need_replacing.any? &&
        @application_form.application_choices.first.awaiting_references?
    end
  end
end
