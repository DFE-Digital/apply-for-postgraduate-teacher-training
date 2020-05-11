module ProviderInterface
  class UserListCardComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :provider_user, :manageable_providers, :full_name, :email_address

    def initialize(provider_user:, manageable_providers:)
      @provider_user = provider_user
      @manageable_providers = manageable_providers
      @full_name = provider_user.full_name
      @email_address = provider_user.email_address
    end

    def providers_text
      providers = provider_user.providers.where(id: manageable_providers.pluck(:id)).order(:name)

      return providers.first.name if providers.size == 1

      "#{providers.first.name} and #{TextCardinalizer.call(providers.size - 1)} more"
    end
  end
end
