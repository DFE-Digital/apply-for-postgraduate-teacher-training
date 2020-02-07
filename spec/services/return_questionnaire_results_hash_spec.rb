require 'rails_helper'

RSpec.describe ReturnQuestionnaireResultsHash do
  describe '#call' do
    it 'returns a hash with the correct values' do
      params = {
        'experience_rating' => 'very_good',
        'experience_explanation_very_poor' => 'should not be returned',
        'experience_explanation_poor' => 'should not be returned',
        'experience_explanation_ok' => 'should not be returned',
        'experience_explanation_good' => 'should not be returned',
        'experience_explanation_very_good' => 'definitely should be returned',
        'guidance_rating' => 'good',
        'guidance_explanation_very_poor' => 'should not be returned',
        'guidance_explanation_poor' => 'should not be returned',
        'guidance_explanation_ok' => 'should not be returned',
        'guidance_explanation_good' => 'definitely should be returned',
        'guidance_explanation_very_good' => 'should not be returned',
        'safe_to_work_with_children' => 'false',
        'safe_to_work_with_children_explanation' => 'This should show',
        'consent_to_be_contacted' => 'true',
        'consent_to_be_contacted_details' => 'anytime 012345 678900',
      }

      correct_params = {
       'experience_rating' => 'very_good',
       'experience_explanation' => 'definitely should be returned',
       'guidance_rating' => 'good',
       'guidance_explanation' => 'definitely should be returned',
       'safe_to_work_with_children' => 'false',
       'safe_to_work_with_children_explanation' => 'This should show',
       'consent_to_be_contacted' => 'true',
       'consent_to_be_contacted_details' => 'anytime 012345 678900',
     }

      expect(described_class.call(params: params)).to eq correct_params
    end
  end
end
