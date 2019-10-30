require 'rails_helper'

RSpec.describe CandidateInterface::DegreesForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:qualification_type) }
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:institution_name) }
    it { is_expected.to validate_presence_of(:grade) }
    it { is_expected.to validate_presence_of(:award_year) }

    it "validates presence of `other_grade` if chosen grade is 'other'" do
      degrees_form = CandidateInterface::DegreesForm.new(grade: 'other')
      error_message = t('activemodel.errors.models.candidate_interface/degrees_form.attributes.other_grade.blank')

      degrees_form.validate

      expect(degrees_form.errors.full_messages_for(:other_grade)).to eq(
        ["Other grade #{error_message}"],
      )
    end

    it "validates presence of `predicted_grade` if chosen grade is 'predicted'" do
      degrees_form = CandidateInterface::DegreesForm.new(grade: 'predicted')
      error_message = t('activemodel.errors.models.candidate_interface/degrees_form.attributes.predicted_grade.blank')

      degrees_form.validate

      expect(degrees_form.errors.full_messages_for(:predicted_grade)).to eq(
        ["Predicted grade #{error_message}"],
      )
    end

    it { is_expected.to validate_length_of(:qualification_type).is_at_most(255) }
    it { is_expected.to validate_length_of(:subject).is_at_most(255) }
    it { is_expected.to validate_length_of(:institution_name).is_at_most(255) }
    it { is_expected.to validate_length_of(:other_grade).is_at_most(255) }
    it { is_expected.to validate_length_of(:predicted_grade).is_at_most(255) }

    describe 'award year' do
      ['a year', '200'].each do |invalid_date|
        it "is invalid if the award year is '#{invalid_date}'" do
          degrees_form = CandidateInterface::DegreesForm.new(award_year: invalid_date)
          error_message = t('activemodel.errors.models.candidate_interface/degrees_form.attributes.award_year.invalid')

          degrees_form.validate

          expect(degrees_form.errors.full_messages_for(:award_year)).to eq(
            ["Award year #{error_message}"],
          )
        end
      end

      it 'is valid if the award year is 4 digits' do
        degrees_form = CandidateInterface::DegreesForm.new(award_year: '2009')
        error_message = t('activemodel.errors.models.candidate_interface/degrees_form.attributes.award_year.invalid')

        degrees_form.validate

        expect(degrees_form.errors.full_messages_for(:award_year)).not_to eq(
          ["Award year #{error_message}"],
        )
      end
    end
  end

  describe '#save_base' do
    it 'returns false if not valid' do
      degree = CandidateInterface::DegreesForm.new

      expect(degree.save_base(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      form_data = {
        qualification_type: 'BA',
        subject: 'maths',
        institution_name: 'University of Much Wow',
        grade: 'first',
        award_year: '2008',
      }
      application_form = create(:application_form)
      degree = CandidateInterface::DegreesForm.new(form_data)

      expect(degree.save_base(application_form)).to eq(true)
      expect(application_form.application_qualifications.degree.first)
        .to have_attributes(form_data)
    end
  end
end
