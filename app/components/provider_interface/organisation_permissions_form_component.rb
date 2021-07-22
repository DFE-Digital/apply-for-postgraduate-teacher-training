module ProviderInterface
  class OrganisationPermissionsFormComponent < ViewComponent::Base
    attr_reader :presenter, :permission_model, :mode, :form_url

    def initialize(provider_user:, provider_relationship_permission:, mode:, form_url:)
      @permission_model = PermissionFormModel.new(provider_relationship_permission)
      @presenter = ProviderRelationshipPermissionAsProviderUserPresenter.new(provider_relationship_permission, provider_user)
      @mode = mode
      @form_url = form_url
    end

    def page_caption
      if mode == :edit
        presenter.provider_relationship_description
      elsif mode == :setup
        t('.setup.caption')
      end
    end

    def page_heading
      if mode == :edit
        t('.edit.heading')
      elsif mode == :setup
        presenter.provider_relationship_description
      end
    end

    def label_for(permission_name)
      permission_description = t("provider_relationship_permissions.#{permission_name}.description")
      t('provider_relationship_permissions.question', permission_description: permission_description.downcase)
    end

    class PermissionFormModel
      include ActiveModel::Model

      attr_reader :provider_relationship_permissions

      delegate :model_name, :errors, to: :provider_relationship_permissions

      def initialize(provider_relationship_permissions)
        @provider_relationship_permissions = provider_relationship_permissions
      end

      ProviderRelationshipPermissions::PERMISSIONS.each do |permission_name|
        define_method(permission_name) do
          %w[training ratifying].select { |provider_type| provider_relationship_permissions.send("#{provider_type}_provider_can_#{permission_name}") }
        end
      end
    end
  end
end
