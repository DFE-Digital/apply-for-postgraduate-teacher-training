require 'rails_helper'

RSpec.describe Provider, type: :model do
  describe '.with_users_manageable_by' do
    it 'scopes results to providers where the user is permitted to manage other users' do
      provider = create(:provider)
      create(:provider)
      provider_user = create(:provider_user, providers: [provider])
      provider_user.provider_permissions.update_all(manage_users: true)

      expect(described_class.with_users_manageable_by(provider_user)).to eq([provider])
    end
  end

  describe '.with_permissions_visible_to' do
    it 'scopes results to providers the given user can manage permissions for' do
      a_provider = create(:provider)
      training_provider = create(:provider, name: 'ZZZ')
      ratifying_provider = create(:provider, name: 'AAA')

      provider_user = create(:provider_user, providers: [training_provider, ratifying_provider, a_provider])
      create(
        :accredited_body_permissions,
        ratifying_provider: ratifying_provider,
        training_provider: training_provider,
      )
      create(
        :training_provider_permissions,
        ratifying_provider: ratifying_provider,
        training_provider: training_provider,
      )

      expect(described_class.with_permissions_visible_to(provider_user)).to eq(
        [ratifying_provider, training_provider],
      )
    end
  end

  describe '#onboarded?' do
    it 'depends on the presence of a signed Data sharing agreement' do
      provider_with_dsa = create(:provider, :with_signed_agreement)
      provider_without_dsa = create(:provider)

      expect(provider_with_dsa).to be_onboarded
      expect(provider_without_dsa).not_to be_onboarded
    end
  end

  describe '#all_associated_accredited_providers_onboarded?' do
    let(:provider) { create(:provider) }

    subject(:result) { provider.all_associated_accredited_providers_onboarded? }

    it 'returns true when the accredited bodies are all onboarded' do
      create(:course, provider: provider, accredited_provider: create(:provider, :with_signed_agreement))

      expect(result).to be true
    end

    it 'returns false when some accredited bodies are onboarded' do
      create(:course, provider: provider, accredited_provider: create(:provider, :with_signed_agreement))
      create(:course, provider: provider, accredited_provider: create(:provider))

      expect(result).to be false
    end

    it 'returns false when there are no accredited bodies' do
      create(:course, provider: provider, accredited_provider: create(:provider))

      expect(result).to be false
    end
  end
end
