module ProviderInterface
  class OrganisationPermissionsSetupCheckComponent < ViewComponent::Base
    attr_reader :current_provider_user, :grouped_relationships_by_name

    def initialize(relationships:, current_provider_user:)
      @grouped_relationships_by_name = ProviderRelationshipPermissionSetupPresenter.new(relationships, current_provider_user).grouped_provider_permissions_by_name
      @current_provider_user = current_provider_user
    end

    def multiple_providers_to_set_up?
      @multiple_providers_to_set_up ||= grouped_relationships_by_name.length > 1
    end
  end
end
