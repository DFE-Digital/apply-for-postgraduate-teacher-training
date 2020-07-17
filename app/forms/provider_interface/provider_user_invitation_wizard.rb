module ProviderInterface
  class ProviderUserInvitationWizard
    include ActiveModel::Model
    STATE_STORE_KEY = :provider_user_invitation_wizard

    attr_accessor :current_step, :current_provider_id, :first_name, :last_name, :email_address, :checking_answers
    attr_writer :providers, :provider_permissions, :state_store

    validates :first_name, presence: true, on: :details
    validates :last_name, presence: true, on: :details
    validates :email_address, presence: true, on: :details
    validates :email_address, email: true, on: :details
    validates :providers, presence: true, on: :providers

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(JSON.parse(last_saved_state).deep_merge(attrs))
    end

    def providers
      if @providers
        @providers.reject(&:blank?).map(&:to_i)
      else
        []
      end
    end

    def provider_permissions
      @provider_permissions || {}
    end

    def applicable_provider_permissions
      @provider_permissions.select do |id, _details|
        providers.include?(id.to_i)
      end
    end

    def permissions_for(provider_id)
      provider_permissions[provider_id].presence || { provider_id: provider_id, permissions: [] }
    end

    def valid_for_current_step?
      valid?(current_step.to_sym)
    end

    # returns [step, *params] for the next step.
    #
    # this way the wizard is responsible for its own routing
    # but it doesn't need to know about HTTP, so we can test it
    # in isolation
    def next_step
      if checking_answers
        if any_provider_needs_permissions_setup
          [:permissions, next_provider_needing_permissions_setup]
        else
          [:check]
        end
      elsif current_step == 'details'
        [:providers]
      elsif %w[providers permissions].include?(current_step) && next_provider_id.present?
        [:permissions, next_provider_id]
      else
        [:check]
      end
    end

    def previous_step
      if checking_answers
        [:check]
      elsif current_step == 'details'
        [:index]
      elsif current_step == 'providers'
        [:details]
      elsif current_step == 'permissions'
        previous_provider_id.present? ? [:permissions, previous_provider_id] : [:providers]
      elsif current_step == 'check'
        providers.present? ? [:permissions, providers.last] : [:providers]
      else
        [:check]
      end
    end

    def save!
      raise NotImplementedError, 'Persistence not implemented yet'
    end

    def save_state!
      @state_store[STATE_STORE_KEY] = state
    end

    def clear_state!
      @state_store.delete(STATE_STORE_KEY)
    end

  private

    def state
      as_json(except: %w[state_store errors validation_context checking_answers current_step current_provider_id]).to_json
    end

    def last_saved_state
      @state_store[STATE_STORE_KEY].presence || '{}'
    end

    def next_provider_id
      if current_provider_id.blank?
        providers.first
      else
        index = providers.index(current_provider_id.to_i)
        index.present? && index < (providers.size - 1) ? providers[index + 1] : nil
      end
    end

    def next_provider_needing_permissions_setup
      providers.find { |p| provider_permissions.keys.exclude?(p.to_s) }
    end

    def any_provider_needs_permissions_setup
      next_provider_needing_permissions_setup.present?
    end

    def previous_provider_id
      if current_provider_id.present?
        index = providers.index(current_provider_id.to_i)
        index&.positive? ? providers[index - 1] : nil
      else
        providers.last
      end
    end
  end
end
