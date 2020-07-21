module CandidateInterface
  class Gcse::InstitutionCountryController < Gcse::DetailsController
    before_action :redirect_to_dashboard_if_submitted, :set_subject, :render_404_if_flag_is_inactive

    def edit
      @institution_country = find_or_build_qualification_form
    end

    def update
      @institution_country = find_or_build_qualification_form

      @institution_country.institution_country = params.dig('candidate_interface_gcse_institution_country_form', 'institution_country')

      if @institution_country.save(@current_qualification)
        update_gcse_completed(false)

        redirect_to next_gcse_path
      else
        track_validation_error(@institution_country)
        render :edit
      end
    end

  private

    def render_404_if_flag_is_inactive
      render_404 and return unless FeatureFlag.active?('international_gcses')
    end

    def find_or_build_qualification_form
      @current_qualification = current_application.qualification_in_subject(:gcse, subject_param)

      if @current_qualification
        GcseInstitutionCountryForm.build_from_qualification(@current_qualification)
      else
        GcseInstitutionCountryForm.new(
          subject: subject_param,
          level: ApplicationQualification.levels[:gcse],
        )
      end
    end

    def next_gcse_path
      @details_form = GcseQualificationDetailsForm.build_from_qualification(
        current_application.qualification_in_subject(:gcse, subject_param),
      )
      if @details_form.qualification.grade.nil?
        candidate_interface_gcse_details_edit_grade_path
      else
        candidate_interface_gcse_review_path
      end
    end
  end
end
