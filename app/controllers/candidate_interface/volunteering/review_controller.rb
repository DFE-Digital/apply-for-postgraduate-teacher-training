module CandidateInterface
  class Volunteering::ReviewController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_not_amendable

    def show
      @application_form = current_application
    end

    def complete
      current_application.update!(application_form_params)

      redirect_to candidate_interface_application_form_path
    end

  private

    def application_form_params
      params.require(:application_form).permit(:volunteering_completed)
        .transform_values(&:strip)
    end
  end
end
