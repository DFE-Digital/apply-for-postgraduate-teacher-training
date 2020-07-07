Raven.configure do |config|
  config.silence_ready = true
  config.current_environment = HostingEnvironment.environment_name
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.excluded_exceptions += [
    'ActionController::BadRequest',
    'ActionController::UnknownFormat',
    'ActionController::UnknownHttpMethod',
    'ActionDispatch::Http::Parameters::ParseError',
    'Redis::CannotConnectError',
    'SyncAllProvidersFromFind::SyncFindApiError',
  ]
end
