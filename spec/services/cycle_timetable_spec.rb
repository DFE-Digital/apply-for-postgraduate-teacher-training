require 'rails_helper'

RSpec.describe CycleTimetable do
  let(:one_hour_before_apply1_deadline) { CycleTimetable.apply_1_deadline(2020) - 1.hour }
  let(:one_hour_after_apply1_deadline) { CycleTimetable.apply_1_deadline(2020) + 1.hour  }
  let(:one_hour_before_apply2_deadline) { CycleTimetable.apply_2_deadline(2020) - 1.hour }
  let(:one_hour_after_apply2_deadline) { CycleTimetable.apply_2_deadline(2020) + 1.hour  }
  let(:one_hour_after_2020_cycle_opens) { CycleTimetable.apply_opens(2020) + 1.hour }
  let(:one_hour_after_2021_cycle_opens) { CycleTimetable.apply_opens(2021) + 1.hour }
  let(:one_hour_before_find_closes) { CycleTimetable.find_closes(2020) - 1.hour }
  let(:one_hour_after_find_closes) { CycleTimetable.find_closes(2020) + 1.hour }
  let(:one_hour_after_find_opens) { CycleTimetable.find_opens(2020) + 1.hour }

  describe '.current_year' do
    it 'is 2020 if we are in the middle of the 2020 cycle' do
      Timecop.travel(one_hour_after_2020_cycle_opens) do
        expect(CycleTimetable.current_year).to eq(2020)
      end
    end

    it 'is 2021 if we are in the middle of the 2021 cycle' do
      Timecop.travel(one_hour_after_2021_cycle_opens) do
        expect(CycleTimetable.current_year).to eq(2021)
      end
    end
  end

  describe '.next_year' do
    it 'is 2021 if we are in the middle of the 2020 cycle' do
      Timecop.travel(one_hour_after_2020_cycle_opens) do
        expect(CycleTimetable.next_year).to eq(2021)
      end
    end

    it 'is 2022 if we are in the middle of the 2021 cycle' do
      Timecop.travel(one_hour_after_2021_cycle_opens) do
        expect(CycleTimetable.next_year).to eq(2022)
      end
    end
  end

  describe '.show_apply_1_deadline_banner?' do
    it 'returns true before the configured date and it is an unsuccessful apply_1 application' do
      application_form = build(:application_form, phase: 'apply_1')

      Timecop.travel(one_hour_before_apply1_deadline) do
        expect(CycleTimetable.show_apply_1_deadline_banner?(application_form)).to be true
      end
    end

    it 'returns false if it is a apply_2 application' do
      application_form = build(:application_form, phase: 'apply_2')

      Timecop.travel(one_hour_before_apply1_deadline) do
        expect(CycleTimetable.show_apply_1_deadline_banner?(application_form)).to be false
      end
    end

    it 'returns false if it is a successful application' do
      application_choice = build(:application_choice, :with_offer)
      application_form = build(:application_form, phase: 'apply_1', application_choices: [application_choice])

      Timecop.travel(one_hour_before_apply1_deadline) do
        expect(CycleTimetable.show_apply_1_deadline_banner?(application_form)).to be false
      end
    end

    it 'returns false after the configured date' do
      application_form = build(:application_form, phase: 'apply_1')

      Timecop.travel(one_hour_after_apply1_deadline) do
        expect(CycleTimetable.show_apply_1_deadline_banner?(application_form)).to be false
      end
    end
  end

  describe '.show_apply_2_deadline_banner?' do
    it 'returns true before the configured date and it is a phase 2 application' do
      application_form = build(:application_form, phase: 'apply_2')

      Timecop.travel(one_hour_before_apply2_deadline) do
        expect(CycleTimetable.show_apply_2_deadline_banner?(application_form)).to be true
      end
    end

    it 'returns false if it is a successful apply_1 application' do
      application_choice = build(:application_choice, :with_offer)
      application_form = build(:application_form, phase: 'apply_1', application_choices: [application_choice])

      Timecop.travel(one_hour_before_apply2_deadline) do
        expect(CycleTimetable.show_apply_2_deadline_banner?(application_form)).to be false
      end
    end

    it 'returns false after the configured date' do
      unsuccessful_application_form = build(:application_form, phase: 'apply_2', application_choices: [build(:application_choice, :with_rejection)])

      Timecop.travel(one_hour_after_apply2_deadline) do
        expect(CycleTimetable.show_apply_2_deadline_banner?(unsuccessful_application_form)).to be false
      end
    end
  end

  describe '.between_cycles_apply_1?' do
    it 'returns false before the configured date' do
      Timecop.travel(one_hour_before_apply1_deadline) do
        expect(CycleTimetable.between_cycles_apply_1?).to be false
      end
    end

    it 'returns true after the configured date' do
      Timecop.travel(one_hour_after_apply1_deadline) do
        expect(CycleTimetable.between_cycles_apply_1?).to be true
      end
    end

    it 'returns false after the new cycle opens' do
      Timecop.travel(one_hour_after_2021_cycle_opens) do
        expect(CycleTimetable.between_cycles_apply_1?).to be false
      end
    end
  end

  describe '.between_cycles_apply_2?' do
    it 'returns false before the configured date' do
      Timecop.travel(one_hour_before_apply2_deadline) do
        expect(CycleTimetable.between_cycles_apply_2?).to be false
      end
    end

    it 'returns true after the configured date' do
      Timecop.travel(one_hour_after_apply2_deadline) do
        expect(CycleTimetable.between_cycles_apply_2?).to be true
      end
    end

    it 'returns false after the new cycle opens' do
      Timecop.travel(one_hour_after_2021_cycle_opens) do
        expect(CycleTimetable.between_cycles_apply_2?).to be false
      end
    end
  end

  describe '.find_down?' do
    it 'returns false before find closes' do
      Timecop.travel(one_hour_before_find_closes) do
        expect(CycleTimetable.find_down?).to be false
      end
    end

    it 'returns false after find_reopens' do
      Timecop.travel(one_hour_after_find_opens) do
        expect(CycleTimetable.find_down?).to be false
      end
    end

    it 'returns true between find_closes and find_reopens' do
      Timecop.travel(one_hour_after_find_closes) do
        expect(CycleTimetable.find_down?).to be true
      end
    end
  end

  describe '.valid_cycle?' do
    def create_application_for(recruitment_cycle_year)
      create :application_form, recruitment_cycle_year: recruitment_cycle_year
    end

    it 'returns true for an application for courses in the current cycle' do
      expect(
        described_class.valid_cycle?(create_application_for(RecruitmentCycle.current_year)),
      ).to be true
    end

    it 'returns false for an application for courses in the previous cycle' do
      expect(
        described_class.valid_cycle?(create_application_for(RecruitmentCycle.previous_year)),
      ).to be false
    end
  end

  describe 'can_add_course_choice?' do
    let(:execute_service) { described_class.can_add_course_choice?(application_form) }

    context 'application form is in the apply1 state' do
      let(:application_form) { build_stubbed(:application_form) }

      context 'when the date is after the apply1 submission deadline' do
        it 'returns false' do
          Timecop.travel(one_hour_after_apply1_deadline) do
            expect(execute_service).to eq false
          end
        end
      end

      context 'when the date is before the apply1 submission deadline' do
        it 'returns true' do
          Timecop.travel(one_hour_before_apply1_deadline) do
            expect(execute_service).to eq true
          end
        end
      end
    end

    context 'application form is in the apply again state' do
      let(:application_form) { build_stubbed(:application_form, phase: :apply_2) }

      context 'when the date is after the apply again submission deadline' do
        it 'returns false' do
          Timecop.travel(one_hour_after_apply2_deadline) do
            expect(execute_service).to eq false
          end
        end
      end

      context 'when the date is before the apply again submission deadline' do
        it 'returns true' do
          Timecop.travel(one_hour_before_apply2_deadline) do
            expect(execute_service).to eq true
          end
        end
      end
    end

    context 'application form is from a previous recruitment cycle' do
      let(:application_form) { build_stubbed(:application_form, recruitment_cycle_year: 2020) }

      it 'returns false' do
        Timecop.travel(CycleTimetable.apply_opens) do
          expect(execute_service).to eq false
        end
      end
    end
  end

  describe '.can_submit?' do
    before { allow(RecruitmentCycle).to receive(:current_year).and_return(2021) }

    it 'returns true for an application in the current recruitment cycle' do
      application_form = build :application_form, recruitment_cycle_year: 2021
      expect(described_class.can_submit?(application_form)).to be true
    end

    it 'returns false for an application in the previous recruitment cycle' do
      application_form = build :application_form, recruitment_cycle_year: 2020
      expect(described_class.can_submit?(application_form)).to be false
    end
  end

  describe '.need_to_send_deadline_reminder?' do
    it 'does not return for a non deadline date' do
      Timecop.travel(CycleTimetable.apply_1_deadline_first_reminder - 1.day) do
        expect(described_class.need_to_send_deadline_reminder?).to be nil
      end
    end

    it 'returns apply_1 when it is the first apply 1 deadline' do
      Timecop.travel(CycleTimetable.apply_1_deadline_first_reminder) do
        expect(described_class.need_to_send_deadline_reminder?).to be :apply_1
      end
    end

    it 'returns apply_1 when it is the second apply 1 deadline' do
      Timecop.travel(CycleTimetable.apply_1_deadline_second_reminder) do
        expect(described_class.need_to_send_deadline_reminder?).to be :apply_1
      end
    end

    it 'returns apply_2 when it is the first apply 2 deadline' do
      Timecop.travel(CycleTimetable.apply_2_deadline_first_reminder) do
        expect(described_class.need_to_send_deadline_reminder?).to be :apply_2
      end
    end

    it 'returns apply_2 when it is the second apply 2 deadline' do
      Timecop.travel(CycleTimetable.apply_2_deadline_second_reminder) do
        expect(described_class.need_to_send_deadline_reminder?).to be :apply_2
      end
    end
  end

  describe 'apply_1_deadline_has_passed?' do
    context 'it is before the apply 1 deadline' do
      it 'returns false' do
        Timecop.travel(CycleTimetable.apply_opens) do
          application_form = build(:application_form)
          expect(described_class.apply_1_deadline_has_passed?(application_form)).to be(false)
        end
      end
    end

    context 'it is after the apply 1 deadline' do
      it 'returns true' do
        Timecop.travel(CycleTimetable.apply_2_deadline) do
          application_form = build(:application_form)
          expect(described_class.apply_1_deadline_has_passed?(application_form)).to be(true)
        end
      end
    end
  end

  describe 'apply_2_deadline_has_passed?' do
    context 'it is before the apply 2 deadline' do
      it 'returns false' do
        Timecop.travel(CycleTimetable.apply_opens) do
          application_form = build(:application_form)
          expect(described_class.apply_1_deadline_has_passed?(application_form)).to be(false)
        end
      end
    end

    context 'it is after the apply 1 deadline' do
      it 'returns true' do
        Timecop.travel(CycleTimetable.find_closes) do
          application_form = build(:application_form)
          expect(described_class.apply_1_deadline_has_passed?(application_form)).to be(true)
        end
      end
    end
  end

  describe '.cycle_year_range' do
    context 'with no year passed in' do
      it 'returns the `current_year to next_year`' do
        allow(CycleTimetable).to receive(:current_year).and_return(2021)
        expect(described_class.cycle_year_range).to eq '2021 to 2022'
      end
    end

    context 'with a year passed in' do
      it 'returns `year to year + 1`' do
        expect(described_class.cycle_year_range(2022)).to eq '2022 to 2023'
      end
    end
  end

  describe 'cycle switcher' do
    it 'correctly sets can_add_course_choice? and can_submit? between cycles' do
      SiteSetting.set(name: 'cycle_schedule', value: :today_is_mid_cycle)

      application_form = create(:application_form, phase: 'apply_1')

      SiteSetting.set(name: 'cycle_schedule', value: :today_is_after_apply_1_deadline_passed)

      new_application = CarryOverApplication.new(application_form).call

      expect(described_class.can_add_course_choice?(new_application)).to be false
      expect(described_class.can_submit?(new_application)).to be false

      SiteSetting.set(name: 'cycle_schedule', value: :today_is_after_find_opens)

      expect(described_class.can_add_course_choice?(new_application)).to be_truthy
      expect(described_class.can_submit?(new_application)).to be false

      SiteSetting.set(name: 'cycle_schedule', value: :today_is_after_apply_opens)

      expect(described_class.can_add_course_choice?(new_application)).to be_truthy
      expect(described_class.can_submit?(new_application)).to be true
    ensure
      SiteSetting.set(name: 'cycle_schedule', value: nil)
    end
  end
end
