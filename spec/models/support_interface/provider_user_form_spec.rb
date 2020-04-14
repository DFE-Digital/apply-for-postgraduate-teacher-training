require 'rails_helper'

RSpec.describe SupportInterface::ProviderUserForm do
  let(:email_address) { 'provider@example.com' }
  let(:provider_ids) { [] }
  let(:form_params) do
    {
      first_name: 'Jane',
      last_name: 'Smith',
      email_address: email_address,
      provider_ids: provider_ids,
    }
  end

  subject(:provider_user_form) { described_class.new(form_params) }

  describe 'validations' do
    context 'email address exists' do
      before { allow(ProviderUser).to receive(:exists?).with(email_address: email_address).and_return(true) }

      it 'is invalid' do
        expect(provider_user_form.valid?).to be false
        expect(provider_user_form.errors[:email_address]).not_to be_empty
      end
    end

    context 'provider_ids are blank' do
      it 'is invalid' do
        expect(provider_user_form.valid?).to be false
        expect(provider_user_form.errors[:provider_ids]).not_to be_empty
      end
    end
  end

  describe '#save' do
    context 'with invalid params' do
      it 'returns nil' do
        expect(provider_user_form.save).to be nil
      end
    end

    context 'with valid params' do
      let(:provider) { create(:provider) }
      let(:provider_ids) { [provider.id] }

      it 'saves a new ProviderUser' do
        provider_user_form.save
        provider_user = ProviderUser.last

        expect(provider_user_form.persisted?).to be true
        expect(provider_user.providers).to eq([provider])
      end
    end
  end
end
