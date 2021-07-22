module ProviderInterface
  class DeclineOrWithdrawApplication
    def initialize(actor:, application_choice:)
      @actor = actor
      @application_choice = application_choice
      @resolve_ucas_match = withdrawing?
    end

    def save!
      return false unless declining? || withdrawing?

      auth.assert_can_make_decisions!(application_choice: @application_choice, course_option: @application_choice.current_course_option)
      ActiveRecord::Base.transaction do
        if declining?
          ApplicationStateChange.new(@application_choice).decline!
          @application_choice.update!(
            declined_at: Time.zone.now,
            audit_comment: I18n.t('transient_application_states.withdrawn_at_candidates_request.declined.audit_comment'),
          )
        elsif withdrawing?
          ApplicationStateChange.new(@application_choice).withdraw!
          @application_choice.update!(
            withdrawn_at: Time.zone.now,
            audit_comment: I18n.t('transient_application_states.withdrawn_at_candidates_request.withdrawn.audit_comment'),
          )
          SetDeclineByDefault.new(application_form: @application_choice.application_form).call
        end
      end

      if @application_choice.application_form.ended_without_success?
        StateChangeNotifier.new(:withdrawn_at_candidates_request, @application_choice).application_outcome_notification
      end

      SendCandidateWithdrawnOnRequestEmail.new(application_choice: application_choice).call

      ResolveUCASMatch.new(application_choice: @application_choice).call if resolve_ucas_match?

      true
    end

  private

    attr_reader :application_choice

    def declining?
      application_choice.offer?
    end

    def withdrawing?
      ApplicationStateChange.new(application_choice).can_withdraw?
    end

    def resolve_ucas_match?
      @resolve_ucas_match
    end

    def auth
      @auth ||= ProviderAuthorisation.new(actor: @actor)
    end

    def transition
      declining? ? :declined : :withdrawn
    end
  end
end
