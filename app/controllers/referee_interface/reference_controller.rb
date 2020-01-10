module RefereeInterface
  class ReferenceController < ActionController::Base
    include LogQueryParams
    before_action :add_identity_to_log
    before_action :check_referee_has_valid_token
    before_action :set_token_param

    layout 'application'

    def feedback
      if reference.feedback_requested?
        @application = reference.application_form
        @reference_form = ReferenceFeedbackForm.new(reference: reference)
      else
        render :finish
      end
    end

    def submit_feedback
      @application = reference.application_form

      @reference_form = ReferenceFeedbackForm.new(
        reference: reference,
        feedback: params[:referee_interface_reference_feedback_form][:feedback],
      )

      if @reference_form.save
        redirect_to referee_interface_confirmation_path(token: @token_param)
      else
        render :feedback
      end
    end

    def confirmation; end

    def confirm_consent
      consent_to_be_contacted = params.dig(:application_reference, :consent_to_be_contacted)

      reference.update!(consent_to_be_contacted: consent_to_be_contacted)

      render :finish
    end

  private

    def add_identity_to_log
      return if reference.blank?

      RequestLocals.store[:identity] = { reference_id: reference.id }
      Raven.user_context(reference_id: reference.id)
    end

    def reference
      @reference ||= ApplicationReference.find_by_unhashed_token(params[:token])
    end

    def set_token_param
      @token_param = params[:token]
    end

    def check_referee_has_valid_token
      render_404 unless reference
    end

    def render_404
      render 'errors/not_found', status: :not_found
    end
  end
end
