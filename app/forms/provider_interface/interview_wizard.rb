module ProviderInterface
  class InterviewWizard
    include ActiveModel::Model
    include ActiveModel::Attributes

    VALID_TIME_FORMAT = /^(1[0-2]|0?[1-9])([:\.\s]?[0-5][0-9])?([AaPp][Mm])$/.freeze

    attr_accessor :time, :location, :additional_details, :provider_id, :application_choice, :provider_user, :current_step
    attr_writer :date

    attribute 'date(3i)', :string
    attribute 'date(2i)', :string
    attribute 'date(1i)', :string

    validate :date_is_valid?
    validate :date_in_future, if: :date_is_valid?
    validate :time_is_valid?, if: ->(wizard) { wizard.time.present? }
    validate :date_after_rbd_date, if: :date_is_valid?
    validates :time, :date, :provider_user, :location, :application_choice, presence: true

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(last_saved_state.deep_merge(attrs))
    end

    def date
      day = send('date(3i)')
      month = send('date(2i)')
      year = send('date(1i)')

      begin
        @date = Date.new(year.to_i, month.to_i, day.to_i)
      rescue ArgumentError
        @date = Struct.new(:day, :month, :year).new(day, month, year)
      end
    end

    def date_is_valid?
      return true if date.is_a?(Date)

      return false if errors.added?(:date)

      empty_keys = date.to_h.select { |_, v| v.blank? }.keys
      errors.add(:date, :blank) and return(false) if empty_keys == date.to_h.keys
      errors.add(:date, :missing_values, missing_details: empty_keys.to_sentence) and return(false) if empty_keys.any?

      errors.add(:date, :invalid)
      false
    end

    def date_and_time
      Time.zone.local(date.year, date.month, date.day, parsed_time.hour, parsed_time.min) if date.is_a?(Date)
    end

    def date_in_future
      errors.add(:date, :past) if date < Time.zone.now
    end

    def date_after_rbd_date
      errors.add(:date, :after_rdb) if date > application_choice.reject_by_default_at
    end

    def parsed_time
      Time.zone.parse(time.gsub(/[ .]/, ':'))
    end

    def time_is_valid?
      return true if time.match(VALID_TIME_FORMAT)

      errors.add(:time, :invalid)
      false
    end

    def provider
      if user_can_make_decisions_for_multiple_providers?
        provider_user.providers.find(provider_id)
      else
        providers_that_user_has_make_decisions_for.first
      end
    end

    def user_can_make_decisions_for_multiple_providers?
      providers_that_user_has_make_decisions_for.count > 1
    end

    def providers_that_user_has_make_decisions_for
      @_providers_that_user_has_make_decisions_for ||= begin
        application_choice_providers = [@application_choice.provider, @application_choice.accredited_provider].compact
        # TODO: Need to check permissions here so that user deffo has the rights
        current_user_providers = provider_user
          .provider_permissions
          .includes([:provider])
          .make_decisions
          .map(&:provider)

        current_user_providers.select { |provider| application_choice_providers.include?(provider) }
      end
    end

    def save_state!
      @state_store.write(state)
    end

    def clear_state!
      @state_store.delete
    end

  private

    def last_saved_state
      saved_state = @state_store.read
      saved_state ? JSON.parse(saved_state) : {}
    end

    def state
      as_json(except: %w[state_store errors validation_context]).to_json
    end
  end
end
