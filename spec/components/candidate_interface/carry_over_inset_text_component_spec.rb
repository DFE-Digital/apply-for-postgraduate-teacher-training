require 'rails_helper'

RSpec.describe CandidateInterface::CarryOverInsetTextComponent do
  include CycleTimetableHelper

  context 'application is unsuccessful and apply 2 deadline has passed' do
    it 'renders the component' do
      Timecop.freeze(CycleTimetable.apply_2_deadline + 1.hour) do
        application_choice = build(:application_choice, :with_rejection)
        application_form = build(:completed_application_form, application_choices: [application_choice])
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.govuk-button').first.attr('value')).to eq('Apply again')
      end
    end

    context 'after the new recruitment cycle begins' do
      around do |example|
        Timecop.freeze(CycleTimetable.apply_reopens(2022) + 1.day) do
          example.run
        end
      end

      it 'renders the correct academic years' do
        application_choice = build(:application_choice, :with_rejection)
        application_form = build(:completed_application_form,
                                 recruitment_cycle_year: RecruitmentCycle.previous_year,
                                 application_choices: [application_choice])
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.text).to include('You submitted your application for courses starting in the 2021 to 2022 academic year, which have now closed.')
        expect(result.text).to include('You can apply for courses starting in the 2022 to 2023 academic year instead.')
      end
    end

    context 'after the apply_2 deadline but before apply reopens' do
      around do |example|
        Timecop.freeze(CycleTimetable.apply_2_deadline(2021) + 1.day) do
          example.run
        end
      end

      it 'renders the correct academic years' do
        application_choice = build(:application_choice, :with_rejection)
        application_form = build(:completed_application_form,
                                 recruitment_cycle_year: RecruitmentCycle.current_year,
                                 application_choices: [application_choice])
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.text).to include('You submitted your application for courses starting in the 2021 to 2022 academic year, which have now closed.')
        expect(result.text).to include('You can apply for courses starting in the 2022 to 2023 academic year instead.')
      end
    end
  end
end
