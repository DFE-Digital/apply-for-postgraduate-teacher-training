require 'csv'

module SupportInterface
  class PerformanceController < SupportInterfaceController
    def index; end

    def course_stats; end

    def course_options
      @course_options = CourseOption.where('vacancy_status != ?', 'vacancies').includes(:course, :site)
    end

    def reasons_for_rejection
      @reasons_for_rejection_statistics = GetReasonsForRejectionFromApplicationChoices.new.reason_counts
    end

    def unavailable_choices
      @monitor = SupportInterface::ApplicationMonitor.new
    end

    def ucas_matches_stats; end
  end
end
