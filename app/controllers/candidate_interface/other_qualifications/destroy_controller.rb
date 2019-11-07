module CandidateInterface
  class OtherQualifications::DestroyController < CandidateInterfaceController
    def confirm_destroy
      application_form = current_candidate.current_application
      @qualification = OtherQualificationForm.build_from_application(
        application_form,
        current_other_qualification_id,
      )
    end

    def destroy
      current_candidate.current_application
        .application_qualifications
        .find(current_other_qualification_id)
        .destroy!

      redirect_to candidate_interface_review_other_qualifications_path
    end

  private

    def current_other_qualification_id
      params.permit(:id)[:id]
    end
  end
end
