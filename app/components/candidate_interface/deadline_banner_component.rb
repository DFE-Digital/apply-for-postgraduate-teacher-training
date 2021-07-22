class CandidateInterface::DeadlineBannerComponent < ViewComponent::Base
  attr_accessor :phase, :flash_empty

  def initialize(application_form:, flash_empty:)
    @application_form = application_form
    @flash_empty = flash_empty
  end

  def render?
    flash_empty && render_deadline_banner?
  end

  def deadline
    if !CycleTimetable.show_apply_2_deadline_banner?(@application_form)
      apply_1_deadline
    else
      apply_2_deadline
    end
  end

  def academic_year
    "#{application_form_recruitment_cycle_year} to #{application_form_recruitment_cycle_year + 1}"
  end

private

  def render_deadline_banner?
    CycleTimetable.show_apply_1_deadline_banner?(@application_form) || CycleTimetable.show_apply_2_deadline_banner?(@application_form)
  end

  def apply_1_deadline
    {
      date: CycleTimetable.date(:apply_1_deadline).to_s(:govuk_date),
      time: CycleTimetable.date(:apply_1_deadline).to_s(:govuk_time),
    }
  end

  def apply_2_deadline
    {
      date: CycleTimetable.date(:apply_2_deadline).to_s(:govuk_date),
      time: CycleTimetable.date(:apply_2_deadline).to_s(:govuk_time),
    }
  end

  def application_form_recruitment_cycle_year
    @application_form.recruitment_cycle_year
  end
end
