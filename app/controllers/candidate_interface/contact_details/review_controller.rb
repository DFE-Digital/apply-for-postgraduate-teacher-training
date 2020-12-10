module CandidateInterface
  class ContactDetails::ReviewController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def show
      @application_form = current_application
    end

    def complete
      current_application.update!(application_form_params)

      redirect_to candidate_interface_application_form_path
    end

  private

    def application_form_params
      strip_whitespace params.require(:application_form).permit(:contact_details_completed)
    end
  end
end
