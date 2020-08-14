require 'rails_helper'

RSpec.describe CandidateInterface::ReopenBannerComponent do
  describe '#render' do
    let(:application_form) { build(:application_form) }
    let(:flash) { double }

    def set_conditions_for_rendering_banner(phase)
      application_form.phase = phase
      FeatureFlag.activate(:deadline_notices)
      allow(flash).to receive(:empty?).and_return true
      allow(EndOfCycleTimetable).to receive(:show_apply_1_reopen_banner?).and_return(true)
      allow(EndOfCycleTimetable).to receive(:show_apply_2_reopen_banner?).and_return(true)
    end

    it 'renders the banner for an Apply 1 app' do
      set_conditions_for_rendering_banner('apply_1')

      result = render_inline(
        described_class.new(
          phase: application_form.phase,
          flash_empty: flash.empty?,
        ),
      )

      expect(result.text).to include('Applications for courses starting this academic year have now closed')
      expect(result.text).to include('Submit your application from 13 October 2020 for courses starting in the next academic year.')
    end

    it 'renders the banner for an Apply 2 app' do
      set_conditions_for_rendering_banner('apply_2')

      result = render_inline(
        described_class.new(
          phase: application_form.phase,
          flash_empty: flash.empty?,
        ),
      )

      expect(result.text).to include('Applications for courses starting this academic year have now closed')
      expect(result.text).to include('Submit your application from 13 October 2020 for courses starting in the next academic year.')
    end

    it 'does NOT render when we not between cycles' do
      set_conditions_for_rendering_banner('apply_1')
      allow(EndOfCycleTimetable).to receive(:show_apply_1_reopen_banner?).and_return(false)

      result = render_inline(
        described_class.new(
          phase: application_form.phase,
          flash_empty: flash.empty?,
        ),
      )

      expect(result.text).not_to include('Applications for courses starting this academic year have now closed')
    end
  end
end
