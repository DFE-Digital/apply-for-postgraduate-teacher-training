module CandidateInterface
  class Gcse::Science::GradeController < CandidateInterfaceController
    include Gcse::GradeControllerConcern
    before_action :redirect_to_dashboard_if_submitted
    before_action :set_subject

    def edit
      @gcse_grade_form = science_gcse_grade_form
      @qualification_type = gcse_science_qualification.qualification_type

      render view_path
    end

    def update
      @gcse_grade_form = science_gcse_grade_form.assign_values(science_details_params)

      if @gcse_grade_form.save
        update_gcse_completed(false)
        redirect_to next_path
      else
        track_validation_error(@gcse_grade_form)
        render view_path
      end
    end

  private

    def view_path
      if gcse_qualification? && FeatureFlag.active?(:multiple_science_gcses)
        'candidate_interface/gcse/science/grade/awards_edit'
      else
        'candidate_interface/gcse/science/grade/edit'
      end
    end

    def next_path
      if science_gcse_grade_form.award_year.nil?
        candidate_interface_gcse_details_edit_year_path(subject: @subject)
      else
        candidate_interface_gcse_review_path(subject: @subject)
      end
    end

    def gcse_qualification?
      gcse_science_qualification.qualification_type == 'gcse'
    end

    def set_subject
      @subject = ApplicationQualification::SCIENCE
    end

    def science_details_params
      strip_whitespace params
        .require(:candidate_interface_science_gcse_grade_form)
        .permit(%i[gcse_science grade single_award_grade double_award_grade biology_grade chemistry_grade physics_grade])
    end

    def gcse_science_qualification
      @gcse_science_qualification ||= current_application.qualification_in_subject(:gcse, @subject)
    end

    def science_gcse_grade_form
      @science_gcse_grade_form ||= ScienceGcseGradeForm.build_from_qualification(gcse_science_qualification)
    end
  end
end
