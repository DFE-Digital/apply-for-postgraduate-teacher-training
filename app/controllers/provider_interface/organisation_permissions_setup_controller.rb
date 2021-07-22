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
      wizard = OrganisationPermissionsSetupWizard.new(
        organisation_permissions_wizard_store,
        current_relationship_id: params[:id],
        current_step: :relationship,
        checking_answers: params[:checking_answers] == 'true',
      )
      wizard.save_state!

      @current_relationship = wizard.current_relationship
      @previous_page_path = previous_page_path(wizard)
    end

    def update
      wizard = OrganisationPermissionsSetupWizard.new(
        organisation_permissions_wizard_store,
        current_relationship_id: params[:id],
        current_step: :relationship,
        provider_relationship_attrs: relationship_hash,
      )

      @current_relationship = wizard.current_relationship
      render :edit and return if @current_relationship.invalid?(:setup)

      wizard.save_state!

      next_step, next_relationship_id = wizard.next_step
      if next_step == :relationship
        redirect_to edit_provider_interface_organisation_permissions_setup_path(next_relationship_id)
      else
        redirect_to check_provider_interface_organisation_permissions_setup_index_path
      end
    end

    def check
      wizard = OrganisationPermissionsSetupWizard.new(organisation_permissions_wizard_store, current_step: :check)
      @relationships = wizard.relationships
      @previous_page_path = previous_page_path(wizard)
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

    def current_relationship_description
      ProviderRelationshipPermissionAsProviderUserPresenter.new(@current_relationship, current_provider_user).provider_relationship_description
    end

    helper_method :current_relationship_description

    def previous_page_path(wizard)
      previous_step, previous_relationship_id = wizard.previous_step
      if previous_step == :relationship
        edit_provider_interface_organisation_permissions_setup_path(previous_relationship_id)
      elsif previous_step == :check
        check_provider_interface_organisation_permissions_setup_index_path
      else
        provider_interface_organisation_permissions_setup_index_path
      end
    end

    def relationship_hash
      { params[:id] => permissions_params }
    end

    def permissions_params
      return {} unless params.key?(:provider_relationship_permissions)

      params.require(:provider_relationship_permissions)
            .permit(make_decisions: [],
                    view_safeguarding_information: [],
                    view_diversity_information: []).to_h
    end
  end
end
