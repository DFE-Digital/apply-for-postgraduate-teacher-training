require 'rails_helper'

RSpec.describe SupportInterface::CandidateSurveyExport do
  describe '#data_for_export' do
    it 'returns a hash of candidates satisfaction survey answers' do
      application_form1 = create(:completed_application_form, :with_survey_completed)
      application_form2 = create(:completed_application_form, :with_survey_completed)
      application_form3 = create(:completed_application_form, :with_survey_completed)
      create(:completed_application_form)

      expect(described_class.new.data_for_export).to match_array([return_expected_hash(application_form1), return_expected_hash(application_form2), return_expected_hash(application_form3)])
    end
  end

private

  def return_expected_hash(application_form)
    survey = application_form.satisfaction_survey

    survey_fields = SatisfactionSurvey::QUESTIONS_WE_ASK
      .index_with { |question| survey[question] }
    {
      'Name' => application_form.full_name,
      'Recruitment cycle year' => application_form.recruitment_cycle_year,
      'Email_address' => application_form.candidate.email_address,
      'Phone number' => application_form.phone_number,
    }.merge(survey_fields)
  end
end
