require 'rails_helper'

RSpec.describe ProviderRelationshipPermissionsParamsHelper do
  describe '#translate_params_for_model' do
    let(:permissions_params) do
      {
        'make_decisions' => %w[training],
        'view_safeguarding_information' => %w[ratifying],
        'view_diversity_information' => %w[training ratifying],
      }
    end
    let(:translated_params) { helper.translate_params_for_model(permissions_params) }

    it 'translates form-style parameters into model compatible attributes' do
      expect(translated_params['training_provider_can_make_decisions']).to be true
      expect(translated_params['ratifying_provider_can_make_decisions']).to be false
      expect(translated_params['training_provider_can_view_safeguarding_information']).to be false
      expect(translated_params['ratifying_provider_can_view_safeguarding_information']).to be true
      expect(translated_params['training_provider_can_view_diversity_information']).to be true
      expect(translated_params['ratifying_provider_can_view_diversity_information']).to be true
    end
  end
end
