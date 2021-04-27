module CandidateInterface
  class SubmittedApplicationFormController < CandidateInterfaceController
    def review_submitted
      @application_form = ApplicationForm.find_by(id: params[:id]) || current_application
    end

    def complete
      @candidate = current_candidate
      @application_form = current_application
    end

    def apply_again
      if ApplyAgain.new(current_application).call
        flash[:success] = 'We’ve copied your application. Please review all sections.'
        redirect_to candidate_interface_application_form_path
      end
    end

    def start_carry_over
      render EndOfCycleTimetable.between_cycles_apply_2? ? :start_carry_over_between_cycles : :start_carry_over
    end

    def carry_over
      CarryOverApplication.new(current_application).call
      flash[:success] = 'Your application is ready for editing'
      redirect_to candidate_interface_before_you_start_path
    end
  end
end
