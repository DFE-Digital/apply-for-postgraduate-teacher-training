module CandidateInterface
  class Gcse::GradeController < Gcse::DetailsController
    before_action :redirect_to_dashboard_if_submitted
    before_action :set_subject

    def update
      @qualification_type = details_form.qualification.qualification_type

      details_form.grade = details_params[:grade]
      details_form.other_grade = details_params[:other_grade]

      @application_qualification = details_form.save_grade

      if @application_qualification
        update_gcse_completed(false)
        redirect_to next_gcse_path
      else
        @application_qualification = details_form
        track_validation_error(@application_qualification)

        render :edit
      end
    end

  private

    def autocomplete_grades?
      @subject.in?(%w[maths english]) && @qualification_type == 'gcse'
    end
    helper_method :autocomplete_grades?

    def next_gcse_path
      if details_form.award_year.nil?
        candidate_interface_gcse_details_edit_year_path
      else
        candidate_interface_gcse_review_path
      end
    end
  end
end
