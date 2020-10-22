module CandidateInterface
  class OtherQualifications::DestroyController < OtherQualificationsBaseController
    def confirm_destroy
      current_qualification = current_application.application_qualifications.other.find(current_other_qualification_id)
      @qualification = OtherQualificationForm.build_from_qualification(current_qualification)
    end

    def destroy
      current_application
        .application_qualifications
        .find(current_other_qualification_id)
        .destroy!

      current_application.update!(other_qualifications_completed: false)

      redirect_to candidate_interface_review_other_qualifications_path
    end

  private

    def current_other_qualification_id
      params.permit(:id)[:id]
    end
  end
end
