require 'rails_helper'

RSpec.describe ProviderInterface::ProviderRelationshipPermissionSetupPresenter do
  let(:provider_1) { create(:provider, name: 'First provider') }
  let(:provider_2) { create(:provider, name: 'Second provider') }
  let(:provider_user) { create(:provider_user, providers: [provider_1, provider_2]) }
  let(:org_permissions_list) do
    other_provider_1 = create(:provider, name: 'B provider')
    other_provider_2 = create(:provider, name: 'A provider')
    other_provider_3 = create(:provider, name: 'School provider')
    [
      create(:provider_relationship_permissions, training_provider: provider_1, ratifying_provider: other_provider_1),
      create(:provider_relationship_permissions, training_provider: provider_1, ratifying_provider: other_provider_2),
      create(:provider_relationship_permissions, ratifying_provider: provider_2, training_provider: other_provider_3),
    ]
  end
  let(:presenter) { described_class.new(org_permissions_list, provider_user) }

  describe '#grouped_provider_names' do
    it 'returns a hash with the main provider names as keys sorted alphabetically' do
      sorted_names = [provider_1.name, provider_2.name].sort
      expect(presenter.grouped_provider_names.keys).to eq(sorted_names)
    end

    it 'returns a hash with values sorted alphabetically' do
      grouped_provider_names = presenter.grouped_provider_names
      expect(grouped_provider_names[provider_1.name]).to eq(['A provider', 'B provider'])
      expect(grouped_provider_names[provider_2.name]).to contain_exactly('School provider')
    end
  end

  describe '#grouped_provider_permissions_by_name' do
    it 'returns a hash with the main provider names as keys sorted alphabetically' do
      sorted_names = [provider_1.name, provider_2.name].sort
      expect(presenter.grouped_provider_permissions_by_name.keys).to eq(sorted_names)
    end

    it 'returns a hash with the sorted provider relationships as values' do
      grouped_provider_permissions_by_name = presenter.grouped_provider_permissions_by_name
      expect(grouped_provider_permissions_by_name[provider_1.name]).to eq([org_permissions_list.second, org_permissions_list.first])
      expect(grouped_provider_permissions_by_name[provider_2.name]).to contain_exactly(org_permissions_list.last)
    end
  end

  describe '#sorted_provider_permission_ids' do
    it 'returns the ids of the permissions objects sorted by main provider name and then by other provider name' do
      expect(presenter.sorted_provider_permission_ids).to eq([
        org_permissions_list.second.id,
        org_permissions_list.first.id,
        org_permissions_list.last.id,
      ])
    end
  end
end
