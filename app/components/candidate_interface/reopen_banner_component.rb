class CandidateInterface::ReopenBannerComponent < ViewComponent::Base
  attr_accessor :phase, :flash_empty

  def initialize(phase:, flash_empty:)
    @phase = phase
    @flash_empty = flash_empty
  end

  def render?
    flash_empty &&
      (show_apply_1_reopen_banner? || show_apply_2_reopen_banner?)
  end

private

  def show_apply_1_reopen_banner?
    apply_1? && CycleTimetable.between_cycles_apply_1?
  end

  def show_apply_2_reopen_banner?
    apply_2? && CycleTimetable.between_cycles_apply_2?
  end

  def apply_1?
    phase == 'apply_1'
  end

  def apply_2?
    phase == 'apply_2'
  end

  def reopen_date
    if Time.zone.now < CycleTimetable.date(:apply_opens)
      {
        date: CycleTimetable.apply_opens.to_s(:govuk_date),
        time: CycleTimetable.apply_opens.to_s(:govuk_time),
      }
    else
      {
        date: CycleTimetable.apply_reopens.to_s(:govuk_date),
        time: CycleTimetable.apply_reopens.to_s(:govuk_time),
      }
    end
  end

  def cycle_year
    @_cycle_year ||= if Time.zone.now < CycleTimetable.apply_opens
                       CycleTimetable.current_year - 1
                     else
                       CycleTimetable.current_year
                     end
  end
end
