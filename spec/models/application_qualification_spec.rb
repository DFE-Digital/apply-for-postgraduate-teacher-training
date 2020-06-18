require 'rails_helper'

RSpec.describe ApplicationQualification, type: :model do
  it 'includes the fields for a degree, GCSE and other qualification level' do
    qualification = ApplicationQualification.new

    expect(qualification.attributes).to include(
      'level',
      'qualification_type',
      'subject',
      'grade',
      'predicted_grade',
      'start_year',
      'award_year',
      'institution_name',
      'institution_country',
      'awarding_body',
      'equivalency_details',
    )
  end

  describe 'level' do
    it 'only accepts degree, gcse and other' do
      %w[degree gcse other].each do |level|
        expect { ApplicationQualification.new(level: level) }.not_to raise_error
      end
    end

    it 'raises an error when level is invalid' do
      expect { ApplicationQualification.new(level: 'invalid_level') }
        .to raise_error ArgumentError, "'invalid_level' is not a valid level"
    end
  end

  describe 'auditing', with_audited: true do
    it 'creates audit entries' do
      application_form = create :application_form
      application_qualification = create :application_qualification, application_form: application_form
      expect(application_qualification.audits.count).to eq 1
      expect {
        application_qualification.update!(subject: 'Rocket Surgery')
      }.to change { application_qualification.audits.count }.by(1)
    end

    it 'creates an associated object in each audit record' do
      application_form = create :application_form
      application_qualification = create :application_qualification, application_form: application_form
      expect(application_qualification.audits.last.associated).to eq application_qualification.application_form
    end
  end

  describe '#incomplete_degree_information?' do
    it 'returns false if not a degree' do
      qualification = build_stubbed(:gcse_qualification)

      expect(qualification.incomplete_degree_information?).to eq false
    end

    it 'returns false if all expected information is present' do
      qualification = build_stubbed(:degree_qualification)

      expect(qualification.incomplete_degree_information?).to eq false
    end

    it 'returns true if any expected information is missing' do
      qualification = build_stubbed(:degree_qualification)

      ApplicationQualification::EXPECTED_DEGREE_FIELDS.each do |field|
        qualification.send("#{field}=", nil)
        expect(qualification.incomplete_degree_information?).to eq true
      end
    end
  end
end
