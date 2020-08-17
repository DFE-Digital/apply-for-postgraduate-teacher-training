module ProviderInterface
  class ErrorsController < ProviderInterfaceController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_provider_user!

    def not_found
      render 'errors/not_found', status: :not_found
    end
  end
end
