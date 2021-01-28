module SupportInterface
  class ReasonsForRejectionTableComponent < ViewComponent::Base
    include ViewHelper
    attr_accessor :reasons

    TOP_LEVEL_REASONS_I18N_KEYS = {
      candidate_behaviour_y_n: :candidate_behaviour_what_did_the_candidate_do,
      quality_of_application_y_n: :quality_of_application,
      qualifications_y_n: :qualifications_which_qualifications,
      honesty_and_professionalism_y_n: :honesty_and_professionalism,
      safeguarding_y_n: :safeguarding_issues,
      course_full_y_n: :full_course,
      offered_on_another_course_y_n: :offered_on_another_course,
      performance_at_interview_y_n: :interview_performance,
      interested_in_future_applications_y_n: :interested_in_future_applications,
    }.with_indifferent_access

    def initialize(reasons)
      @reasons = reasons
    end

    def reason_label(reason)
      I18n.t("reasons_for_rejection.#{TOP_LEVEL_REASONS_I18N_KEYS[reason]}.title")
    end

    def sub_reason_label(reason, sub_reason)
      I18n.t("reasons_for_rejection.#{TOP_LEVEL_REASONS_I18N_KEYS[reason]}.#{sub_reason}")
    end
  end
end
