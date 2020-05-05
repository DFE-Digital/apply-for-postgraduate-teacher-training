require 'rails_helper'

RSpec.describe ProviderInterface::ProviderUserForm do
  let(:current_provider_user) { create(:provider_user, providers: providers) }
  let(:provider) { create(:provider) }
  let(:providers) { [provider] }
  let(:provider_user) { create(:provider_user, providers: providers) }
  let(:provider_permissions) do
    {
      provider.id => {
        provider_permission: {
          provider_id: provider.id,
          provider_user_id: provider_user.id,
        },
        active: true,
      },
    }
  end
  let(:form_params) do
    {
      current_provider_user: current_provider_user,
      provider_user: provider_user,
      provider_permissions: provider_permissions,
    }
  end

  subject(:provider_user_form) { described_class.new(form_params) }

  before { current_provider_user.providers.first.provider_permissions.update(manage_users: true) }

  describe 'validations' do
    context 'with no provider_permissions' do
      let(:provider_permissions) { {} }

      it 'is invalid' do
        expect(provider_user_form).not_to be_valid
        expect(provider_user_form.errors[:provider_permissions]).not_to be_empty
      end
    end

    context 'with provider_permissions for providers the current user cannot manage' do
      let(:another_provider) { create(:provider) }
      let(:provider_permissions) do
        {
          another_provider.id => {
            provider_permission: {
              provider_id: another_provider.id,
              provider_user_id: provider_user.id,
            },
            active: true,
          },
        }
      end

      it 'is invalid' do
        expect(provider_user_form).not_to be_valid
        expect(provider_user_form.errors[:provider_permissions]).not_to be_empty
      end
    end

    context 'with provider_permissions for providers the current user can manage' do
      it 'is valid' do
        provider_user_form.valid?
        expect(provider_user_form.errors[:provider_permissions]).to be_empty
      end
    end

    context 'name fields' do
      let(:form_params) {
        {
          current_provider_user: provider_user,
          provider_permissions: provider_permissions,
        }
      }

      it 'are required' do
        provider_user_form.valid?

        expect(provider_user_form.errors[:first_name]).not_to be_empty
        expect(provider_user_form.errors[:last_name]).not_to be_empty
      end
    end

    context 'with email address of an existing user' do
      let(:email_address) { 'provider@example.com' }
      let(:existing_user) { create(:provider_user, :with_provider, email_address: email_address) }

      before { form_params[:email_address] = existing_user.email_address }

      it 'is valid' do
        expect(provider_user_form).to be_valid
      end
    end
  end

  describe '#possible_permissions' do
    let(:providers) do
      [
        create(:provider, name: 'ABC'),
        create(:provider, name: 'AAA'),
        create(:provider, name: 'ABB'),
      ]
    end

    before { current_provider_user.provider_permissions.update_all(manage_users: true) }

    it 'returns a collection of provider permissions the current provider user can assign to other users' do
      possible_permissions = provider_user_form.possible_permissions.map { |p| p.provider.name }
      expect(possible_permissions).to eq(%w[AAA ABB ABC])
    end
  end

  describe '#build' do
    let(:email_address) { 'provider@example.com' }
    let(:form_params) do
      {
        first_name: 'Jane',
        last_name: 'Smith',
        email_address: email_address,
        current_provider_user: current_provider_user,
        provider_permissions: provider_permissions,
      }
    end

    context 'for a new user' do
      it 'returns a new user' do
        expect(provider_user_form.build.persisted?).to be false
      end
    end

    context 'for an existing user' do
      let!(:existing_user) { create(:provider_user, :with_provider, email_address: email_address) }

      it 'modifies and returns the existing user' do
        expect(provider_user_form.build.persisted?).to be true
        expect(provider_user_form.build).to eq(existing_user)
      end
    end

    context 'for an existing user also belonging to non visible providers' do
      let(:non_visible_provider) { create(:provider) }
      let(:providers) { [provider, non_visible_provider] }

      before { create(:provider_user, providers: providers, email_address: email_address) }

      it 'only builds permissions for visible providers' do
        expect(provider_user_form.provider_permissions.map(&:provider)).to eq([provider])
      end
    end
  end
end
