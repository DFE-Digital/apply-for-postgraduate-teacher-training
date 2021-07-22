require 'rails_helper'

RSpec.describe CandidateInterface::DeadlineBannerComponent, type: :component do
  describe '#render' do
    let(:application_form) { build(:application_form) }
    let(:flash) { double }

    it 'does not render when flash is not empty' do
      allow(flash).to receive(:empty?).and_return(false)
      allow(CycleTimetable).to receive(:show_apply_1_deadline_banner?).and_return(true)
      allow(CycleTimetable).to receive(:show_apply_2_deadline_banner?).and_return(true)

      result = render_inline(described_class.new(application_form: application_form, flash_empty: flash.empty?))

      expect(result.text).to eq('')
    end

    it 'does not render when a deadline banner should not be shown' do
      allow(flash).to receive(:empty?).and_return(true)
      allow(CycleTimetable).to receive(:show_apply_1_deadline_banner?).and_return(false)
      allow(CycleTimetable).to receive(:show_apply_2_deadline_banner?).and_return(false)

      result = render_inline(described_class.new(application_form: application_form, flash_empty: flash.empty?))

      expect(result.text).to eq('')
    end

    it 'renders the Apply 1 banner when the right conditions are met' do
      allow(flash).to receive(:empty?).and_return(true)
      allow(CycleTimetable).to receive(:show_apply_1_deadline_banner?).and_return(true)
      allow(CycleTimetable).to receive(:show_apply_2_deadline_banner?).and_return(false)

      result = render_inline(described_class.new(application_form: application_form, flash_empty: flash.empty?))

      expect(result.text).to include(
        "The deadline for applying to courses starting in the #{academic_year} academic year is #{deadline_time(:apply_1_deadline)} on #{deadline_date(:apply_1_deadline)}",
      )
    end

    it 'renders the Apply 2 banner when the right conditions are met' do
      allow(flash).to receive(:empty?).and_return(true)
      allow(CycleTimetable).to receive(:show_apply_1_deadline_banner?).and_return(false)
      allow(CycleTimetable).to receive(:show_apply_2_deadline_banner?).and_return(true)

      result = render_inline(described_class.new(application_form: application_form, flash_empty: flash.empty?))

      expect(result.text).to include(
        "The deadline for applying to courses starting in the #{academic_year} academic year is #{deadline_time(:apply_2_deadline)} on #{deadline_date(:apply_2_deadline)}",
      )
    end
  end

  def academic_year
    "#{application_form.recruitment_cycle_year} to #{application_form.recruitment_cycle_year + 1}"
  end

  def deadline_time(deadline)
    CycleTimetable.date(deadline).to_s(:govuk_time)
  end

  def deadline_date(deadline)
    CycleTimetable.date(deadline).to_s(:govuk_date)
  end
end
