module ProviderInterface
  class ProviderRelationshipPermissionsController < ProviderInterfaceController
    before_action :render_404_unless_permissions_found

    def success; end

    def edit
      initialize_form
    end

    def confirm
      initialize_form
      @form.assign_permissions_attributes(provider_relationship_permissions_form_params)
    end

    def update
      initialize_form
      @form.assign_permissions_attributes(provider_relationship_permissions_form_params)

      if @form.save!
        redirect_to provider_interface_provider_relationship_permissions_success_path
      else
        flash[:warning] = 'Unable to save permissions, please try again. If problems persist please contact support.'
        render :edit
      end
    end

  private

    def initialize_form
      @form = ProviderRelationshipPermissionsForm.new(
        accredited_body_permissions: accredited_body_permissions,
        training_provider_permissions: training_provider_permissions,
      )
    end

    def accredited_body_permissions
      @accredited_body_permissions ||= AccreditedBodyPermissions.find_by(provider_relationship_params)
    end

    def training_provider_permissions
      @training_provider_permissions ||= TrainingProviderPermissions.find_by(provider_relationship_params)
    end

    def provider_relationship_params
      params.permit(:ratifying_provider_id, :training_provider_id)
    end

    def provider_relationship_permissions_form_params
      permissions_attrs = %i[view_safeguarding_information]
      params.require(:provider_interface_provider_relationship_permissions_form)
        .permit(
          accredited_body_permissions: permissions_attrs,
          training_provider_permissions: permissions_attrs,
        ).to_h
    end

    def render_404_unless_permissions_found
      render_404 if accredited_body_permissions.blank? || training_provider_permissions.blank?
    end
  end
end
