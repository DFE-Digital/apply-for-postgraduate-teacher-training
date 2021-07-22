module ProviderInterface
  class OrganisationPermissionsSetupWizard
    include ActiveModel::Model
    include ProviderRelationshipPermissionsParamsHelper

    attr_accessor :relationship_ids, :current_relationship_id, :current_step, :checking_answers
    attr_writer :state_store, :provider_relationship_attrs

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(last_saved_state.deep_merge(attrs))

      self.checking_answers = false if current_step == :check
    end

    def current_relationship
      build_relationship_for_id(current_relationship_id)
    end

    def next_step
      return [:check] if checking_answers || next_relationship_id.nil?

      [:relationship, next_relationship_id]
    end

    def previous_step
      return [:relationship, relationship_ids.last] if current_step == :check

      return [:check] if checking_answers

      [:relationship, previous_relationship_id] if previous_relationship_id.present?
    end

    def save_state!
      @state_store.write(state)
    end

    def clear_state!
      @state_store.delete
    end

    def relationships
      relationship_ids.map { |id| build_relationship_for_id(id) }
    end

  private

    def build_relationship_for_id(relationship_id)
      relationship = ProviderRelationshipPermissions.find(relationship_id)
      assign_wizard_attrs_to_relationship(relationship)
      relationship
    end

    def next_relationship_id
      next_relationship_index = relationship_ids.find_index(current_relationship_id.to_i) + 1
      relationship_ids[next_relationship_index]
    end

    def previous_relationship_id
      previous_relationship_index = relationship_ids.find_index(current_relationship_id.to_i) - 1
      return nil if previous_relationship_index.negative?

      relationship_ids[previous_relationship_index]
    end

    def provider_relationship_attrs
      @provider_relationship_attrs.presence || {}
    end

    def state
      as_json(except: %w[state_store errors validation_context]).to_json
    end

    def last_saved_state
      state = @state_store.read

      if state
        JSON.parse(state)
      else
        {}
      end
    end

    def assign_wizard_attrs_to_relationship(relationship)
      relationship.assign_attributes(wizard_attrs_for_relationship(relationship))
      relationship
    end

    def wizard_attrs_for_relationship(relationship)
      permission_attrs = provider_relationship_attrs[relationship.id.to_s]
      return {} if permission_attrs.blank?

      translate_params_for_model(permission_attrs)
    end
  end
end
