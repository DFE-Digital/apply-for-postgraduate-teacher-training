module SupportInterface
  class ApplicationCardComponent < ViewComponent::Base
    include ViewHelper

    attr_accessor :application_form, :updated_at, :support_reference

    def initialize(application_form:)
      @application_form = application_form
      @support_reference = application_form.support_reference
      @updated_at = application_form.updated_at.to_s(:govuk_date_and_time)
    end

    def candidate_name
      application_form.full_name.presence || application_form.candidate.email_address
    end

    def application_choices
      application_form.application_choices.includes(%i[course provider])
    end

    def overall_status
      process_state = ProcessState.new(application_form).state
      I18n.t!("candidate_flow_application_states.#{process_state}.name")
    end

    def apply_again_context
      if application_form.apply_2?
        "(#{application_form.recruitment_cycle_year}, apply again)"
      elsif application_form.candidate_has_previously_applied?
        "(#{application_form.recruitment_cycle_year}, carried over)"
      else
        "(#{application_form.recruitment_cycle_year})"
      end
    end
  end
end
