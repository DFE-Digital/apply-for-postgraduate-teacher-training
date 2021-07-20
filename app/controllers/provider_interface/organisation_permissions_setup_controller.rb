module ProviderInterface
  class OrganisationPermissionsSetupController < ProviderInterfaceController
    before_action :require_manage_organisations_permission!
    before_action :redirect_unless_permissions_to_setup

    def index
      permission_setup_presenter = ProviderRelationshipPermissionSetupPresenter.new(
        provider_relationship_permissions_needing_setup,
        current_provider_user,
      )
      @sorted_and_grouped_provider_names = permission_setup_presenter.grouped_provider_names
      @sorted_relationship_ids = permission_setup_presenter.sorted_provider_permission_ids
      OrganisationPermissionsSetupWizard.new(organisation_permissions_wizard_store, relationship_ids: @sorted_relationship_ids).save_state!
    end

    def edit
      wizard = OrganisationPermissionsSetupWizard.new(organisation_permissions_wizard_store, current_relationship_id: params[:id])
      @current_relationship = wizard.current_relationship
      @current_relationship_description = ProviderRelationshipPermissionAsProviderUserPresenter.new(@current_relationship, current_provider_user).provider_relationship_description
    end

  private

    def require_access_to_manage_provider_relationship_permissions!
      provider_relationship_permissions = ProviderRelationshipPermissions.find(params[:id])
      permitted_relationship_permissions = current_provider_user.authorisation.training_provider_relationships_that_actor_can_manage_organisations_for

      render_403 unless permitted_relationship_permissions.include?(provider_relationship_permissions)
    end

    def redirect_unless_permissions_to_setup
      redirect_to provider_interface_applications_path if provider_relationship_permissions_needing_setup.blank?
    end

    def provider_relationship_permissions_needing_setup
      ProviderSetup.new(provider_user: current_provider_user).relationships_pending
    end

    def require_manage_organisations_permission!
      render_404 unless current_provider_user.authorisation.can_manage_organisations_for_at_least_one_provider?
    end

    def organisation_permissions_wizard_store
      key = "organisation_permissions_wizard_store_#{current_provider_user.id}"
      WizardStateStores::RedisStore.new(key: key)
    end
  end
end
