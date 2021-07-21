module Events
  class Event
    EVENT_TYPES = %w[web_request create_entity update_entity].freeze

    def initialize
      @event_hash = {
        environment: HostingEnvironment.environment_name,
        occurred_at: Time.zone.now.iso8601,
      }
    end

    def as_json
      @event_hash.as_json
    end

    def with_type(type)
      raise 'Invalid analytics event type' unless EVENT_TYPES.include?(type.to_s)

      @event_hash.merge!(
        event_type: type,
      )

      self
    end

    def with_request_details(rack_request)
      @event_hash.merge!(
        request_uuid: rack_request.uuid,
        request_user_agent: rack_request.user_agent,
        request_method: rack_request.method,
        request_path: rack_request.path,
        request_query: hash_to_kv_pairs(Rack::Utils.parse_query(rack_request.query_string)),
        request_referer: rack_request.referer,
        anonymised_user_agent_and_ip: anonymised_user_agent_and_ip(rack_request),
      )

      self
    end

    def with_response_details(rack_response)
      @event_hash.merge!(
        response_content_type: rack_response.content_type,
        response_status: rack_response.status,
      )

      self
    end

    def with_user_and_namespace(user, namespace)
      @event_hash.merge!(
        namespace: namespace,
        user_id: user&.id,
      )

      self
    end

    def with_entity_table_name(table_name)
      @event_hash.merge!(
        entity_table_name: table_name,
      )

      self
    end

    def with_data(hash)
      @event_hash.deep_merge!({
        data: hash_to_kv_pairs(hash),
      })

      self
    end

    def with_tags(tags)
      @event_hash[:event_tags] = tags if tags

      self
    end

  private

    def hash_to_kv_pairs(hash)
      hash.map do |(key, value)|
        if value.in? [true, false]
          value = value.to_s
        end

        { 'key' => key, 'value' => Array.wrap(value) }
      end
    end

    def anonymised_user_agent_and_ip(rack_request)
      if rack_request.remote_ip.present?
        anonymise(rack_request.user_agent.to_s + rack_request.remote_ip.to_s)
      end
    end

    def anonymise(text)
      Digest::SHA2.hexdigest(text)
    end
  end
end
