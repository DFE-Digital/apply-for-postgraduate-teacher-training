module CandidateInterface
  class OtherQualifications::DestroyController < OtherQualifications::OtherQualificationsBaseController
    def confirm_destroy
      @qualification = OtherQualificationForm.build_from_qualification(current_qualification)
    end

    def destroy
      current_qualification.destroy!
      current_application.update!(other_qualifications_completed: false)

      redirect_to candidate_interface_review_other_qualifications_path
    end
  end
end
