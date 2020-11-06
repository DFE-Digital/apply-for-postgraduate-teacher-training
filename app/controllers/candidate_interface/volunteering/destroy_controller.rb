module CandidateInterface
  class Volunteering::DestroyController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def confirm_destroy
      current_experience = current_application.application_volunteering_experiences.find(current_volunteering_role_id)
      @volunteering_role = VolunteeringRoleForm.build_from_experience(current_experience)
    end

    def destroy
      current_application
        .application_volunteering_experiences
        .find(current_volunteering_role_id)
        .destroy!

      if current_application.application_volunteering_experiences.blank?
        current_application.update!(volunteering_completed: false, volunteering_experience: false)
        redirect_to candidate_interface_volunteering_experience_path
      else
        current_application.update!(volunteering_completed: false)
        redirect_to candidate_interface_review_volunteering_path
      end
    end

  private

    def current_volunteering_role_id
      params.permit(:id)[:id]
    end
  end
end
