require 'rails_helper'

RSpec.describe CandidateInterface::VolunteeringRoleForm, type: :model do
  let(:data) do
    {
      role: 'School Experience Intern',
      organisation: Faker::Educator.secondary_school,
      details: Faker::Lorem.paragraph_by_chars(number: 300),
      working_with_children: true,
      start_date: Time.zone.local(2018, 5, 1),
      end_date: Time.zone.local(2019, 5, 1),
    }
  end

  let(:form_data) do
    {
      role: data[:role],
      organisation: data[:organisation],
      details: data[:details],
      working_with_children: data[:working_with_children],
      start_date_month: data[:start_date].month,
      start_date_year: data[:start_date].year,
      end_date_month: data[:end_date].month,
      end_date_year: data[:end_date].year,
    }
  end

  describe '.build_all_from_application' do
    it 'creates an array of objects based on the provided ApplicationForm' do
      application_form = create(:application_form) do |form|
        form.application_volunteering_experiences.create(attributes: data)
        form.application_volunteering_experiences.create(
          role: 'School Experience Intern',
          organisation: 'A Noice School',
          details: 'I interned.',
          working_with_children: true,
          start_date: Time.zone.local(2018, 8, 1),
          end_date: Time.zone.local(2019, 10, 1),
        )
      end

      volunteering_roles = CandidateInterface::VolunteeringRoleForm.build_all_from_application(application_form)

      expect(volunteering_roles).to match_array([
        have_attributes(form_data),
        have_attributes(
          role: 'School Experience Intern',
          organisation: 'A Noice School',
          details: 'I interned.',
          working_with_children: true,
          start_date_month: 8,
          start_date_year: 2018,
          end_date_month: 10,
          end_date_year: 2019,
        ),
      ])
    end
  end

  describe '.build_from_experience' do
    it 'returns a new VolunteeringRoleForm object using an application experience' do
      application_experience = build_stubbed(:application_volunteering_experience, attributes: data)

      volunteering_role = CandidateInterface::VolunteeringRoleForm.build_from_experience(application_experience)

      expect(volunteering_role).to have_attributes(form_data)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      volunteering_role = CandidateInterface::VolunteeringRoleForm.new

      expect(volunteering_role.save(ApplicationForm.new)).to eq(false)
    end

    context 'when a valid volunteering role' do
      let(:application_form) { create(:application_form, volunteering_experience: false) }
      let(:volunteering_role) { CandidateInterface::VolunteeringRoleForm.new(form_data) }

      it 'creates a new work experience if valid' do
        expect(volunteering_role.save(application_form)).to eq(true)
        expect(application_form.application_volunteering_experiences.first)
          .to have_attributes(data)
      end

      it 'updates volunteering experience if valid' do
        volunteering_role.save(application_form)

        expect(application_form.volunteering_experience).to eq(true)
      end
    end
  end

  describe '#update' do
    let(:application_form) { create(:application_form) }
    let(:existing_volunteering) do
      application_form.application_volunteering_experiences.create(attributes: data)
    end
    let(:volunteering_role) { CandidateInterface::VolunteeringRoleForm.new(id: existing_volunteering.id) }

    it 'returns false if not valid' do
      expect(volunteering_role.update(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      form_data[:role] = 'Classroom Volunteer'
      form_data[:organisation] = 'Some Other School'
      volunteering_role.assign_attributes(form_data)

      expect(volunteering_role.update(application_form)).to eq(true)
      expect(application_form.application_volunteering_experiences.first)
        .to have_attributes(
          role: 'Classroom Volunteer',
          organisation: 'Some Other School',
          details: data[:details],
          working_with_children: data[:working_with_children],
          start_date: data[:start_date],
          end_date: data[:end_date],
        )
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:organisation) }
    it { is_expected.to validate_presence_of(:details) }
    it { is_expected.to validate_presence_of(:working_with_children) }

    it { is_expected.to validate_length_of(:role).is_at_most(60) }
    it { is_expected.to validate_length_of(:organisation).is_at_most(60) }

    okay_text = Faker::Lorem.sentence(word_count: 150)
    long_text = Faker::Lorem.sentence(word_count: 151)

    it { is_expected.to allow_value(okay_text).for(:details) }
    it { is_expected.not_to allow_value(long_text).for(:details) }

    include_examples 'validation for a start date', 'volunteering_role_form'
    include_examples 'validation for an end date that can be blank', 'volunteering_role_form'
  end
end
