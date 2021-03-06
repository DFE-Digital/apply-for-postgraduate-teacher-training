require 'rails_helper'

RSpec.describe ProviderInterface::ProviderUsersController, type: :request do
  include DfESignInHelpers
  include ModelWithErrorsStubHelper

  describe 'validation errors' do
    let(:managing_user) { create(:provider_user, :with_manage_organisations, :with_manage_users, providers: [provider]) }
    let(:provider_user) { create(:provider_user, providers: [provider]) }
    let(:provider) { create(:provider, :with_signed_agreement) }

    before do
      allow(DfESignInUser).to receive(:load_from_session).and_return(managing_user)

      user_exists_in_dfe_sign_in(email_address: managing_user.email_address)
    end

    it 'tracks validation errors for GET to edit_permissions' do
      stub_model_instance_with_errors(ProviderInterface::ProviderUserEditPermissionsForm, invalid?: true, :provider_permissions= => nil)

      expect { get provider_interface_provider_user_edit_permissions_path(provider_user, provider) }.to change(ValidationError, :count).by(1)
    end

    it 'tracks validation errors for PATCH to update_permissions' do
      stub_model_instance_with_errors(
        ProviderInterface::ProviderUserEditPermissionsForm,
        save: false, update_from_params: nil, provider: provider, provider_user: provider_user, :provider_permissions= => nil,
        permissions_form: instance_double(
          ProviderInterface::FieldsForProviderUserPermissionsForm, id: '1', provider_id: provider.id, view_applications_only: nil, permissions: {}
        )
      )

      expect {
        patch provider_interface_provider_user_edit_permissions_path(provider_user, provider),
              params: { provider_interface_provider_user_edit_permissions_form: { provider_id: provider.id } }
      }.to change(ValidationError, :count).by(1)
    end

    it 'tracks validation errors for PUT to update_providers' do
      expect { patch provider_interface_provider_user_edit_providers_path(provider_user) }.to change(ValidationError, :count).by(1)
    end
  end
end
