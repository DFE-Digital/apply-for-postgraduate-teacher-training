module CandidateInterface
  class RestructuredWorkHistoryWorkExperienceComponent < ViewComponent::Base
    include ViewHelper

    def initialize(work_experience:, editable: true)
      @work_experience = work_experience
      @editable = editable
    end

  private

    attr_reader :application_form

    def formatted_start_date
      if @work_experience.start_date_unknown
        "#{@work_experience.start_date.to_s(:month_and_year)} (estimate)"
      else
        @work_experience.start_date.to_s(:month_and_year)
      end
    end

    def formatted_end_date
      return 'Present' if @work_experience.currently_working

      if @work_experience.end_date_unknown
        "#{@work_experience.end_date.to_s(:month_and_year)} (estimate)"
      else
        @work_experience.end_date.to_s(:month_and_year)
      end
    end
  end
end
