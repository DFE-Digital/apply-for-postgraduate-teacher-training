module ProviderInterface
  class ProviderRelationshipPermissionSetupPresenter
    def initialize(provider_relationship_permissions_list, provider_user)
      @provider_relationship_permissions_list = provider_relationship_permissions_list
      @provider_user = provider_user
    end

    def grouped_provider_names
      sorted_and_grouped_provider_names_with_relationships.transform_values do |array|
        array.map { |permission| permission[:other_provider_name] }
      end
    end

    def grouped_provider_permissions_by_name
      sorted_and_grouped_provider_names_with_relationships.transform_values do |array|
        array.map { |permission| permission[:organisation_permission] }
      end
    end

    def sorted_provider_permission_ids
      sorted_and_grouped_provider_names_with_relationships.values.flat_map do |array|
        array.map { |permission| permission[:organisation_permission].id }
      end
    end

  private

    attr_reader :provider_relationship_permissions_list, :provider_user

    def sorted_and_grouped_provider_names_with_relationships
      @sorted_and_grouped_provider_names_with_relationships ||= grouped_provider_names_with_relationships
        .sort_by { |main_provider_name, _| main_provider_name }
        .to_h
        .transform_values do |provider_permission|
          provider_permission.sort_by { |hash| hash[:other_provider_name] }
        end
    end

    def grouped_provider_names_with_relationships
      provider_relationship_permissions_list.each_with_object({}) do |prp, h|
        presenter = ProviderRelationshipPermissionAsProviderUserPresenter.new(prp, provider_user)
        main_provider = presenter.ordered_providers.first
        other_provider = presenter.ordered_providers.second
        h[main_provider.name] ||= []
        h[main_provider.name] << { other_provider_name: other_provider.name, organisation_permission: prp }
      end
    end
  end
end
