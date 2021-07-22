module ProviderInterface
  class OrganisationPermissionsController < ProviderInterfaceController
    include ProviderRelationshipPermissionsParamsHelper

    before_action :require_accredited_provider_setting_permissions_flag
    before_action :set_up_relationship_objects, except: %i[organisations index]
    before_action :organisation_id_and_permission_check, except: %i[organisations index]

    # This action and the relevant route will be removed once Organisation Settings
    # is broken down into provider sections.
    def organisations
      @manageable_providers = manageable_providers
    end

    def index
      @provider = current_provider_user.providers.find(params[:organisation_id])
      render_403 unless current_provider_user.authorisation.can_manage_organisation?(provider: @provider)

      unsorted_provider_relationships = ProviderRelationshipPermissions.all_relationships_for_providers([@provider]).where.not(setup_at: nil)
      @provider_relationships = sort_relationships_by_provider_name(unsorted_provider_relationships, @provider)
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def edit; end

    def update
      if @relationship.update(new_relationship_permissions)
        flash[:success] = 'Organisation permissions successfully updated'
        redirect_to provider_interface_organisation_settings_organisation_organisation_permissions_path(params[:organisation_id])
      else
        track_validation_error(@relationship)
        render :edit
      end
    end

  private

    def manageable_providers
      @_manageable_providers ||= current_provider_user.authorisation.providers_that_actor_can_manage_organisations_for(with_set_up_permissions: true)
    end

    def permissions_params
      return {} unless params.key?(:provider_relationship_permissions)

      params.require(:provider_relationship_permissions)
            .permit(make_decisions: [],
                    view_safeguarding_information: [],
                    view_diversity_information: []).to_h
    end

    def new_relationship_permissions
      translate_params_for_model(permissions_params)
    end

    def set_up_relationship_objects
      @relationship = ProviderRelationshipPermissions.find(params[:id])
      @provider = Provider.find(params[:organisation_id])
      @presenter = ProviderRelationshipPermissionAsProviderUserPresenter.new(@relationship, current_provider_user)
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def organisation_id_and_permission_check
      relationship_providers = [@relationship.training_provider, @relationship.ratifying_provider]
      render_404 and return unless relationship_providers.include?(@provider) &&
                                   current_provider_user.providers.include?(@provider)

      auth = ProviderAuthorisation.new(actor: current_provider_user)
      render_403 unless relationship_providers.map { |p| auth.can_manage_organisation?(provider: p) }.any?
    end

    def require_accredited_provider_setting_permissions_flag
      unless FeatureFlag.active?(:accredited_provider_setting_permissions)
        redirect_to(provider_interface_account_path)
      end
    end

    def sort_relationships_by_provider_name(relationships, provider)
      relationships.sort_by do |relationship|
        relationship.training_provider == provider ? relationship.ratifying_provider.name : relationship.training_provider.name
      end
    end
  end
end
