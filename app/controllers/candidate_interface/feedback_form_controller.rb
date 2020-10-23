module CandidateInterface
  class FeedbackFormController < CandidateInterfaceController
    def new
      @feedback_form = FeedbackForm.new
    end

    def create
      @feedback_form = FeedbackForm.new(feedback_params)
      if @feedback_form.save(current_application)
        redirect_to candidate_interface_feedback_form_thank_you_path
      else
        track_validation_error(@feedback_form)
        render :new
      end
    end

    def thank_you; end

  private

    def feedback_params
      params.require(:candidate_interface_feedback_form).permit(
        :satisfaction_level, :suggestions
      )
    end
  end
end
