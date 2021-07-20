require 'rails_helper'

RSpec.describe ProviderInterface::OrganisationPermissionsSetupWizard do
  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:relationships) { create_list(:provider_relationship_permissions, 3).shuffle }
  let(:relationship_ids) { relationships.pluck(:id) }
  let(:wizard_attrs) do
    {
      relationship_ids: relationship_ids,
    }
  end

  let(:wizard) do
    described_class.new(
      store,
      wizard_attrs,
    )
  end

  before { allow(store).to receive(:read) }

  describe '#current_relationship' do
    context 'when the wizard has no stored information for the relationship' do
      let(:wizard_attrs) do
        {
          relationship_ids: relationship_ids,
          current_relationship_id: relationship_ids.last
        }
      end

      it 'returns the relationship with the given id in the list' do
        expect(wizard.current_relationship).to eq(relationships.last)
      end
    end

    context 'when the wizard has stored changes to a relationship' do
      let(:provider_relationship_attrs) do
        {
          relationship_ids.first.to_s => {
            'make_decisions' => %w[ratifying],
            'view_safeguarding_information' => %w[training ratifying],
            'view_diversity_information' => %w[training],
          },
        }
      end
      let(:wizard_attrs) do
        {
          relationship_ids: relationship_ids,
          provider_relationship_attrs: provider_relationship_attrs,
        }
      end

      it 'returns the relationship with the changes applied but not saved' do
        current_relationship = wizard.current_relationship
        expect(current_relationship).to be_changed

        expect(current_relationship.training_provider_can_make_decisions).to eq(false)
        expect(current_relationship.ratifying_provider_can_make_decisions).to eq(true)
        expect(current_relationship.training_provider_can_view_safeguarding_information).to eq(true)
        expect(current_relationship.ratifying_provider_can_view_safeguarding_information).to eq(true)
        expect(current_relationship.training_provider_can_view_diversity_information).to eq(true)
        expect(current_relationship.ratifying_provider_can_view_diversity_information).to eq(false)
      end
    end
  end
end
