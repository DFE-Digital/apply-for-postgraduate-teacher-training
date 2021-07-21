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
          current_relationship_id: relationship_ids.last,
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
          current_relationship_id: relationship_ids.first,
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

  describe '#next_step' do
    context 'when there is a relationship next in the list' do
      let(:wizard_attrs) do
        {
          relationship_ids: relationship_ids,
          current_relationship_id: relationship_ids.first,
        }
      end

      it 'returns :relationship and the id of the next relationship' do
        expect(wizard.next_step).to eq([:relationship, relationship_ids.second])
      end
    end

    context 'when there are no further relationships in the list' do
      let(:wizard_attrs) do
        {
          relationship_ids: relationship_ids,
          current_relationship_id: relationship_ids.last,
        }
      end

      it 'returns :check' do
        expect(wizard.next_step).to eq([:check])
      end
    end

    context 'when checking_answers is true' do
      let(:wizard_attrs) do
        {
          relationship_ids: relationship_ids,
          current_relationship_id: relationship_ids.first,
          checking_answers: true,
        }
      end

      it 'returns :check' do
        expect(wizard.next_step).to eq([:check])
      end
    end
  end

  describe '#previous_step' do
    context 'when there is a relationship before the current one in the list' do
      let(:wizard_attrs) do
        {
          relationship_ids: relationship_ids,
          current_relationship_id: relationship_ids.second,
          current_step: :relationship,
        }
      end

      it 'returns :relationship and the id of the previous relationship' do
        expect(wizard.previous_step).to eq([:relationship, relationship_ids.first])
      end
    end

    context 'when the current relationship is the first' do
      let(:wizard_attrs) do
        {
          relationship_ids: relationship_ids,
          current_relationship_id: relationship_ids.first,
          current_step: :relationship,
        }
      end

      it 'returns nil' do
        expect(wizard.previous_step).to be_nil
      end
    end

    context 'when the current step is :check' do
      let(:wizard_attrs) do
        {
          relationship_ids: relationship_ids,
          current_step: :check,
        }
      end

      it 'returns :relationship and the id of the last relationship' do
        expect(wizard.previous_step).to eq([:relationship, relationship_ids.last])
      end
    end

    context 'when checking_answers is true' do
      let(:wizard_attrs) do
        {
          relationship_ids: relationship_ids,
          current_relationship_id: relationship_ids.first,
          checking_answers: true,
        }
      end

      it 'returns :check' do
        expect(wizard.previous_step).to eq([:check])
      end
    end
  end
end
