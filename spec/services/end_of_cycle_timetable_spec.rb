require 'rails_helper'

RSpec.describe EndOfCycleTimetable do
  let(:one_hour_before_apply1_deadline) { Time.zone.local(2020, 8, 24, 23, 0, 0) }
  let(:one_hour_after_apply1_deadline) { Time.zone.local(2020, 8, 25, 1, 0, 0) }
  let(:one_hour_before_apply2_deadline) { Time.zone.local(2020, 9, 18, 23, 0, 0) }
  let(:one_hour_after_apply2_deadline) { Time.zone.local(2020, 9, 19, 1, 0, 0) }
  let(:one_hour_after_2021_cycle_opens) { Time.zone.local(2020, 10, 13, 1, 0, 0) }

  context 'when `simulate_time_between_cycles` and `simulate_time_mid_cycle` feature flags are NOT active' do
    describe '.show_apply_1_deadline_banner?' do
      it 'returns true before the configured date' do
        Timecop.travel(one_hour_before_apply1_deadline) do
          expect(EndOfCycleTimetable.show_apply_1_deadline_banner?).to be true
        end
      end

      it 'returns false after the configured date' do
        Timecop.travel(one_hour_after_apply1_deadline) do
          expect(EndOfCycleTimetable.show_apply_1_deadline_banner?).to be false
        end
      end
    end

    describe '.show_apply_2_deadline_banner?' do
      it 'returns true before the configured date' do
        Timecop.travel(one_hour_before_apply2_deadline) do
          expect(EndOfCycleTimetable.show_apply_2_deadline_banner?).to be true
        end
      end

      it 'returns false after the configured date' do
        Timecop.travel(one_hour_after_apply2_deadline) do
          expect(EndOfCycleTimetable.show_apply_2_deadline_banner?).to be false
        end
      end
    end

    describe '.between_cycles_apply_1?' do
      it 'returns false before the configured date' do
        Timecop.travel(one_hour_before_apply1_deadline) do
          expect(EndOfCycleTimetable.between_cycles_apply_1?).to be false
        end
      end

      it 'returns true after the configured date' do
        Timecop.travel(one_hour_after_apply1_deadline) do
          expect(EndOfCycleTimetable.between_cycles_apply_1?).to be true
        end
      end

      it 'returns false after the new cycle opens' do
        Timecop.travel(one_hour_after_2021_cycle_opens) do
          expect(EndOfCycleTimetable.between_cycles_apply_1?).to be false
        end
      end
    end

    describe '.between_cycles_apply_2?' do
      it 'returns false before the configured date' do
        Timecop.travel(one_hour_before_apply2_deadline) do
          expect(EndOfCycleTimetable.between_cycles_apply_2?).to be false
        end
      end

      it 'returns true after the configured date' do
        Timecop.travel(one_hour_after_apply2_deadline) do
          expect(EndOfCycleTimetable.between_cycles_apply_2?).to be true
        end
      end

      it 'returns false after the new cycle opens' do
        Timecop.travel(one_hour_after_2021_cycle_opens) do
          expect(EndOfCycleTimetable.between_cycles_apply_2?).to be false
        end
      end
    end
  end

  context 'when `simulate_time_mid_cycle` feature flag is active' do
    before { FeatureFlag.activate(:simulate_time_mid_cycle) }

    describe '.show_apply_1_deadline_banner?' do
      it 'returns true before the configured date' do
        Timecop.travel(one_hour_before_apply1_deadline) do
          expect(EndOfCycleTimetable.show_apply_1_deadline_banner?).to be true
        end
      end

      it 'returns true after the configured date' do
        Timecop.travel(one_hour_after_apply1_deadline) do
          expect(EndOfCycleTimetable.show_apply_1_deadline_banner?).to be true
        end
      end
    end

    describe '.show_apply_2_deadline_banner?' do
      it 'returns true before the configured date' do
        Timecop.travel(one_hour_before_apply2_deadline) do
          expect(EndOfCycleTimetable.show_apply_2_deadline_banner?).to be true
        end
      end

      it 'returns true after the configured date' do
        Timecop.travel(one_hour_after_apply2_deadline) do
          expect(EndOfCycleTimetable.show_apply_2_deadline_banner?).to be true
        end
      end
    end

    describe '.between_cycles_apply_1?' do
      it 'returns false before the configured date' do
        Timecop.travel(one_hour_before_apply1_deadline) do
          expect(EndOfCycleTimetable.between_cycles_apply_1?).to be false
        end
      end

      it 'returns false after the configured date' do
        Timecop.travel(one_hour_after_apply1_deadline) do
          expect(EndOfCycleTimetable.between_cycles_apply_1?).to be false
        end
      end

      it 'returns false after the new cycle opens' do
        Timecop.travel(one_hour_after_2021_cycle_opens) do
          expect(EndOfCycleTimetable.between_cycles_apply_1?).to be false
        end
      end
    end

    describe '.between_cycles_apply_2?' do
      it 'returns false before the configured date' do
        Timecop.travel(one_hour_before_apply2_deadline) do
          expect(EndOfCycleTimetable.between_cycles_apply_2?).to be false
        end
      end

      it 'returns false after the configured date' do
        Timecop.travel(one_hour_after_apply2_deadline) do
          expect(EndOfCycleTimetable.between_cycles_apply_2?).to be false
        end
      end

      it 'returns false after the new cycle opens' do
        Timecop.travel(one_hour_after_2021_cycle_opens) do
          expect(EndOfCycleTimetable.between_cycles_apply_2?).to be false
        end
      end
    end
  end

  context 'when `simulate_time_between_cycles` feature flag is active' do
    before { FeatureFlag.activate(:simulate_time_between_cycles) }

    describe '.show_apply_1_deadline_banner?' do
      it 'returns false before the configured date' do
        Timecop.travel(one_hour_before_apply1_deadline) do
          expect(EndOfCycleTimetable.show_apply_1_deadline_banner?).to be false
        end
      end

      it 'returns false after the configured date' do
        Timecop.travel(one_hour_after_apply1_deadline) do
          expect(EndOfCycleTimetable.show_apply_1_deadline_banner?).to be false
        end
      end
    end

    describe '.show_apply_2_deadline_banner?' do
      it 'returns false before the configured date' do
        Timecop.travel(one_hour_before_apply2_deadline) do
          expect(EndOfCycleTimetable.show_apply_2_deadline_banner?).to be false
        end
      end

      it 'returns false after the configured date' do
        Timecop.travel(one_hour_after_apply2_deadline) do
          expect(EndOfCycleTimetable.show_apply_2_deadline_banner?).to be false
        end
      end
    end

    describe '.between_cycles_apply_1?' do
      it 'returns true before the configured date' do
        Timecop.travel(one_hour_before_apply1_deadline) do
          expect(EndOfCycleTimetable.between_cycles_apply_1?).to be true
        end
      end

      it 'returns true after the configured date' do
        Timecop.travel(one_hour_after_apply1_deadline) do
          expect(EndOfCycleTimetable.between_cycles_apply_1?).to be true
        end
      end

      it 'returns true after the new cycle opens' do
        Timecop.travel(one_hour_after_2021_cycle_opens) do
          expect(EndOfCycleTimetable.between_cycles_apply_1?).to be true
        end
      end
    end

    describe '.between_cycles_apply_2?' do
      it 'returns true before the configured date' do
        Timecop.travel(one_hour_before_apply2_deadline) do
          expect(EndOfCycleTimetable.between_cycles_apply_2?).to be true
        end
      end

      it 'returns true after the configured date' do
        Timecop.travel(one_hour_after_apply2_deadline) do
          expect(EndOfCycleTimetable.between_cycles_apply_2?).to be true
        end
      end

      it 'returns true after the new cycle opens' do
        Timecop.travel(one_hour_after_2021_cycle_opens) do
          expect(EndOfCycleTimetable.between_cycles_apply_2?).to be true
        end
      end
    end
  end

  describe '.next_cycle_year' do
    it 'returns 2021 when in 2020 cycle' do
      Timecop.travel(Time.zone.local(2020, 8, 24, 23, 0, 0)) do
        expect(EndOfCycleTimetable.next_cycle_year).to eq 2021
      end
    end
  end

  describe '.find_down?' do
    it 'returns false before find closes' do
      Timecop.travel(EndOfCycleTimetable.find_closes.beginning_of_day - 1.hour) do
        expect(EndOfCycleTimetable.find_down?).to be false
      end
    end

    it 'returns false after find_reopens' do
      Timecop.travel(EndOfCycleTimetable.find_reopens.end_of_day + 1.hour) do
        expect(EndOfCycleTimetable.find_down?).to be false
      end
    end

    it 'returns true between find_closes and find_reopens' do
      Timecop.travel(EndOfCycleTimetable.find_closes.end_of_day + 1.hour) do
        expect(EndOfCycleTimetable.find_down?).to be true
      end
    end
  end

  describe '.current_cycle?' do
    def create_application_for(recruitment_cycle_year)
      application_form = create :application_form
      create(
        :application_choice,
        application_form: application_form,
        course_option: create(:course_option, course: create(:course, recruitment_cycle_year: recruitment_cycle_year)),
      )
      application_form
    end

    it 'returns true for an application for courses in the current cycle' do
      expect(
        described_class.current_cycle?(create_application_for(RecruitmentCycle.current_year)),
      ).to be true
    end

    it 'returns false for an application for courses in the previous cycle' do
      expect(
        described_class.current_cycle?(create_application_for(RecruitmentCycle.previous_year)),
      ).to be false
    end
  end
end
