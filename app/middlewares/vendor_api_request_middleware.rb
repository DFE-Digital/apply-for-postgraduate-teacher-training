require 'redis'
require './app/workers/vendor_api_request_worker'

class VendorAPIRequestMiddleware
  REQUEST_HEADER_KEYS = %w[
    HTTP_VERSION
    HTTP_HOST
    HTTP_USER_AGENT
    HTTP_ACCEPT
    HTTP_ACCEPT_ENCODING
    HTTP_AUTHORIZATION
    HTTP_CONNECTION
    HTTP_CACHE_CONTROL
  ].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    started_at = Time.zone.now

    @request = Rack::Request.new(env)
    status, headers, response = @app.call(env)

    begin
      if vendor_api_path?
        finished_at = Time.zone.now
        response_time = (finished_at - started_at) * 1000

        VendorAPIRequestWorker.perform_async(request_data, response.body, status, response_time, Time.zone.now)
      end
    rescue Redis::BaseError => e
      Rails.logger.warn e.message
    end

    [status, headers, response]
  end

private

  def request_data
    {
      path: @request.path,
      params: @request.params,
      headers: request_headers,
    }
  end

  def request_headers
    @request.env.slice(*REQUEST_HEADER_KEYS)
  end

  def vendor_api_path?
    @request.path =~ /^\/api\/.*$/
  end
end
