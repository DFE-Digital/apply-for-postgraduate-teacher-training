module CandidateInterface
  class Gcse::ReviewController < Gcse::DetailsController
    before_action :redirect_to_dashboard_if_submitted
    before_action :set_subject
    before_action :set_field_name
    before_action :render_application_feedback_component, except: :complete

    def show
      @application_form = current_application
      @application_qualification = current_application.qualification_in_subject(:gcse, subject_param)
    end

    def complete
      current_application.update!(application_form_params)

      redirect_to candidate_interface_application_form_path
    end

  private

    def set_field_name
      @field_name = "#{@subject}_gcse_completed"
    end

    def application_form_params
      strip_whitespace params.require(:application_form).permit(@field_name)
    end
  end
end
