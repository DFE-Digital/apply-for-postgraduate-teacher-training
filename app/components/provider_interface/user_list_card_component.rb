module ProviderInterface
  class UserListCardComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :provider_user, :providers, :full_name, :email_address

    def initialize(provider_user:, providers:)
      @provider_user = provider_user
      @providers = providers
      @full_name = provider_user.full_name
      @email_address = provider_user.email_address
    end

    def providers_text
      return providers.first.name if providers.size == 1

      "#{providers.first.name} and #{TextCardinalizer.call(providers.size - 1)} more"
    end
  end
end
