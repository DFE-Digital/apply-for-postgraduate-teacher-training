module CandidateInterface
  class CarryOverBannerComponent < ViewComponent::Base
    include ViewHelper
    validates :application_form, presence: true

    def initialize(application_form:)
      @application_form = application_form
    end

    def render?
      if @application_form.ended_without_success?
        @application_form.recruitment_cycle_year < RecruitmentCycle.current_year ||
          EndOfCycleTimetable.between_cycles_apply_2?
      elsif !@application_form.submitted?
        @application_form.recruitment_cycle_year < RecruitmentCycle.current_year &&
          !EndOfCycleTimetable.between_cycles_apply_1?
      end
    end

    def start_path
      candidate_interface_start_carry_over_path
    end
  end
end
