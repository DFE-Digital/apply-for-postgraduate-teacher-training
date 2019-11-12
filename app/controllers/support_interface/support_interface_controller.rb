module SupportInterface
  class SupportInterfaceController < ActionController::Base
    layout 'support_layout'

    http_basic_authenticate_with(
      name: ENV.fetch('SUPPORT_USERNAME'),
      password: ENV.fetch('SUPPORT_PASSWORD'),
    )
  end
end
