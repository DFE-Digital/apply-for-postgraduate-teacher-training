require 'rails_helper'

RSpec.describe CandidateInterface::PersonalDetailsForm, type: :model do
  let(:data) do
    {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      date_of_birth: Faker::Date.birthday,
      first_nationality: NATIONALITY_DEMONYMS.sample,
      second_nationality: NATIONALITY_DEMONYMS.sample,
      english_main_language: [true, false].sample,
      english_language_details: Faker::Lorem.paragraph_by_chars(number: 200),
      other_language_details: Faker::Lorem.paragraph_by_chars(number: 200),
    }
  end

  let(:form_data) do
    {
      first_name: data[:first_name],
      last_name: data[:last_name],
      day: data[:date_of_birth].day,
      month: data[:date_of_birth].month,
      year: data[:date_of_birth].year,
      first_nationality: data[:first_nationality],
      second_nationality: data[:second_nationality],
      english_main_language: data[:english_main_language] ? 'yes' : 'no',
      english_language_details: data[:english_language_details],
      other_language_details: data[:other_language_details],
    }
  end

  describe '#name' do
    it 'concatenates the first name and last name' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(first_name: 'Bruce', last_name: 'Wayne')

      expect(personal_details.name).to eq('Bruce Wayne')
    end
  end

  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      application_form = ApplicationForm.new(data)
      personal_details = CandidateInterface::PersonalDetailsForm.build_from_application(
        application_form,
      )

      expect(personal_details).to have_attributes(form_data)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      personal_details = CandidateInterface::PersonalDetailsForm.new

      expect(personal_details.save(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_form = FactoryBot.create(:application_form)
      personal_details = CandidateInterface::PersonalDetailsForm.new(form_data)

      expect(personal_details.save(application_form)).to eq(true)
      expect(application_form).to have_attributes(data)
    end
  end

  describe '#date_of_birth' do
    it 'returns nil for nil day/month/year' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(day: nil, month: nil, year: nil)

      expect(personal_details.date_of_birth).to eq(nil)
    end

    it 'returns nil for invalid day/month/year' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(day: 99, month: 99, year: 99)

      expect(personal_details.date_of_birth).to eq(nil)
    end

    it 'returns a date for a valid day/month/year' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(day: '2', month: '8', year: '802701')

      expect(personal_details.date_of_birth).to eq(Date.new(802701, 8, 2))
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:first_nationality) }
    it { is_expected.to validate_presence_of(:english_main_language) }

    it { is_expected.to validate_length_of(:first_name).is_at_most(100) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(100) }

    it { is_expected.to validate_inclusion_of(:first_nationality).in_array(NATIONALITY_DEMONYMS) }
    it { is_expected.to validate_inclusion_of(:second_nationality).in_array(NATIONALITY_DEMONYMS) }

    okay_text = Faker::Lorem.sentence(word_count: 200)
    long_text = Faker::Lorem.sentence(word_count: 201)

    it { is_expected.to allow_value(okay_text).for(:english_language_details) }
    it { is_expected.not_to allow_value(long_text).for(:english_language_details) }

    it { is_expected.to allow_value(okay_text).for(:other_language_details) }
    it { is_expected.not_to allow_value(long_text).for(:other_language_details) }

    describe 'date of birth' do
      it 'is invalid if not well-formed' do
        personal_details = CandidateInterface::PersonalDetailsForm.new(
          day: '99', month: '99', year: '99',
        )

        personal_details.validate

        expect(personal_details.errors.full_messages_for(:date_of_birth)).to eq(
          ['Date of birth Enter a date of birth in the correct format, for example 13 1 1993'],
        )
      end

      it 'is invalid if the date is in the past' do
        personal_details = CandidateInterface::PersonalDetailsForm.new(
          day: '2', month: '8', year: '802701',
        )

        personal_details.validate

        expect(personal_details.errors.full_messages_for(:date_of_birth)).to eq(
          ['Date of birth Enter a date of birth that is in the past, for example 13 1 1993'],
        )
      end
    end
  end

  describe '#english_main_language?' do
    it 'returns true if "yes"' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(english_main_language: 'yes')

      expect(personal_details).to be_english_main_language
    end

    it 'returns false if "no"' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(english_main_language: 'no')

      expect(personal_details).not_to be_english_main_language
    end
  end
end
