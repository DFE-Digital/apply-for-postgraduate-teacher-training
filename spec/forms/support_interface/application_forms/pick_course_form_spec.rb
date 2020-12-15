require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::PickCourseForm, type: :model do
  describe '#course_options' do
    let(:first_site) { create(:site) }
    let(:second_site) { create(:site) }
    let(:provider) { create(:provider, sites: [first_site, second_site]) }
    let(:course) { create(:course, code: 'ABC', provider: provider) }

    it 'returns only course options that have vacancies' do
      course_option_with_vacancies = create(:course_option, site_id: first_site.id, course_id: course.id)
      create(:course_option, course_id: course.id, site_id: second_site.id, vacancy_status: 'no_vacancies')
      application_form = create(:completed_application_form)

      form_data = {
        application_form_id: application_form.id,
        course_code: course.code,
      }

      course_options = described_class.new(form_data).course_options

      expect(course_options.length).to eq(1)
      expect(course_options.first.course_option_id).to eq(course_option_with_vacancies.id)
    end

    it 'does not return course options that have already been added to an application form' do
      course_option = create(:course_option, site_id: first_site.id, course_id: course.id)
      application_choice = create(:application_choice, course_option_id: course_option.id)
      application_form = create(:completed_application_form, application_choices: [application_choice])

      form_data = {
        application_form_id: application_form.id,
        course_code: course.code,
      }

      course_options = described_class.new(form_data).course_options

      expect(course_options.length).to eq(0)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      expect(described_class.new.save).to be false
    end

    it 'updates the application form with the course choice' do
      application_form = create(:application_form)
      course_option = create(:course_option)

      form_data = {
        application_form_id: application_form.id,
        course_option_id: course_option.id,
        course_code: course_option.course.code,
      }

      expect(described_class.new(form_data).save).to be_truthy
      expect(application_form.reload.application_choices.last.course_option_id).to eq form_data[:course_option_id]
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:course_option_id) }
    it { is_expected.to validate_presence_of(:application_form_id) }
  end
end
