require 'rails_helper'

RSpec.describe CandidateInterface::CarryOverBannerComponent do
  let(:application_form) { create(:completed_application_form) }

  before { allow(RecruitmentCycle).to receive(:current_year).and_return(2021) }

  context 'after the new recruitment cycle begins' do
    around do |example|
      Timecop.freeze(Time.zone.local(2020, 10, 14, 12, 0, 0)) do
        example.run
      end
    end

    it 'renders nothing when application is recruited and from last recruitment cycle' do
      create(:application_choice, application_form: application_form, status: :recruited)
      application_form.recruitment_cycle_year = 2020
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to be_blank
    end

    it 'renders component when application is rejected from last recruitment cycle' do
      create(:application_choice, :with_rejection, application_form: application_form)
      application_form.recruitment_cycle_year = 2020
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Do you want to continue applying?')
      expect(result.text).to include('Continue your application')
      expect(result.css('a')[0].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_start_carry_over_path)
    end

    it 'renders component when application is unsubmitted from last recruitment cycle' do
      create(:application_choice, application_form: application_form, status: :unsubmitted)
      application_form.recruitment_cycle_year = 2020
      application_form.submitted_at = nil
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Do you want to continue applying?')
      expect(result.text).to include('Continue your application')
      expect(result.css('a')[0].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_start_carry_over_path)
    end

    it 'renders component when application is unsubmitted and without application choices from last recruitment cycle' do
      application_form.recruitment_cycle_year = 2020
      application_form.submitted_at = nil
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Do you want to continue applying?')
      expect(result.text).to include('Continue your application')
      expect(result.css('a')[0].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_start_carry_over_path)
    end

    it 'renders nothing when application is rejected from the current recruitment cycle' do
      create(:application_choice, :with_rejection, application_form: application_form)
      application_form.recruitment_cycle_year = 2021
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to be_blank
    end
  end

  context 'after the apply 2 deadline has passed' do
    around do |example|
      Timecop.freeze(Time.zone.local(2020, 9, 19, 12, 0, 0)) do
        example.run
      end
    end

    it 'renders nothing when application is recruited and from last recruitment cycle' do
      create(:application_choice, application_form: application_form, status: :recruited)
      application_form.recruitment_cycle_year = 2020
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to be_blank
    end

    it 'renders nothing when application is unsubmitted' do
      create(:application_choice, application_form: application_form, status: :unsubmitted)
      application_form.recruitment_cycle_year = 2020
      application_form.submitted_at = nil
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to be_blank
    end

    it 'renders nothing when application is unsubmitted and without application choices' do
      application_form.recruitment_cycle_year = 2020
      application_form.submitted_at = nil
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to be_blank
    end

    it 'renders component when application is rejected from last recruitment cycle' do
      create(:application_choice, :with_rejection, application_form: application_form)
      application_form.recruitment_cycle_year = 2020
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Courses for the 2021 to 2022 academic year are now closed')
      expect(result.css('a')[0].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_start_carry_over_path)
    end

    it 'renders component when application is rejected from the current recruitment cycle' do
      create(:application_choice, :with_rejection, application_form: application_form)
      application_form.recruitment_cycle_year = 2021
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Courses for the 2021 to 2022 academic year are now closed')
      expect(result.css('a')[0].attr('href')).to include(Rails.application.routes.url_helpers.candidate_interface_start_carry_over_path)
    end
  end
end
