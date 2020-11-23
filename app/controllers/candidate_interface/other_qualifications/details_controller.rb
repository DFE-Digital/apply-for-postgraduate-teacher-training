module CandidateInterface
  class OtherQualifications::DetailsController < OtherQualifications::BaseController
    def new
      @form = form_for(current_step: :type)
      @form.qualification_type ||= params[:qualification_type]
      @form.initialize_new_qualification(
        current_application.application_qualifications.other.order(:created_at),
      )
      set_subject_autocomplete_data
      set_grade_autocomplete_data
      @form.save_intermediate!
    end

    def create
      @form = form_for(other_qualification_params.merge(current_step: :details))
      @form.save_intermediate!
      set_subject_autocomplete_data
      set_grade_autocomplete_data

      if @form.valid?(:details)
        @form.save!
        reset_intermediate_state!

        if @form.choice == 'same_type'
          redirect_to candidate_interface_other_qualification_details_path(qualification_type: current_application.application_qualifications.last.qualification_type)
        elsif @form.choice == 'different_type'
          redirect_to candidate_interface_other_qualification_type_path
        else
          redirect_to candidate_interface_review_other_qualifications_path
        end
      elsif @form.missing_type_validation_error?
        flash[:warning] = "To update one of your qualifications use the 'Change' links below."
        redirect_to candidate_interface_review_other_qualifications_path
      else
        track_validation_error(@form)
        render :new
      end
    end

    def edit
      @form = form_for(
        current_step: :details,
        initialize_from_db: true,
        checking_answers: true,
      )
      @form.save_intermediate!
      set_subject_autocomplete_data
      set_grade_autocomplete_data
    end

    def update
      @form = form_for(
        other_qualification_update_params.merge(current_step: :details, checking_answers: true),
      )
      @form.save_intermediate!
      set_subject_autocomplete_data
      set_grade_autocomplete_data

      if @form.valid?(:details)
        @form.save!
        current_application.update!(other_qualifications_completed: false)
        reset_intermediate_state!
        redirect_to candidate_interface_review_other_qualifications_path
      elsif @form.missing_type_validation_error?
        flash[:warning] = "To update one of your qualifications use the 'Change' links below."
        redirect_to candidate_interface_review_other_qualifications_path
      else
        track_validation_error(@form)
        render :edit
      end
    end

  private

    def form_for(options)
      options[:checking_answers] = true if params[:checking_answers] == 'true'
      if options.delete(:initialize_from_db)
        options.merge(current_qualification) if params[:id]
      end

      OtherQualificationDetailForm.new(
        current_application,
        intermediate_data_service,
        options,
      )
    end

    def other_qualification_params
      params.require(:candidate_interface_other_qualification_detail_form).permit(
        :subject,
        :grade,
        :award_year,
        :choice,
        :institution_country,
        :other_uk_qualification_type,
        :non_uk_qualification_type,
      ).merge!(
        id: params[:id],
      )
    end

    def other_qualification_update_params
      other_qualification_params.merge(
        params.require(:candidate_interface_other_qualification_wizard).permit(:qualification_type),
      )
    end

    def set_subject_autocomplete_data
      qualification_type = @wizard.qualification_type_name
      if qualification_type.in? [OtherQualificationWizard::A_LEVEL_TYPE, OtherQualificationWizard::AS_LEVEL_TYPE]
        @subject_autocomplete_data = A_AND_AS_LEVEL_SUBJECTS
      elsif qualification_type == 'GCSE'
        @subject_autocomplete_data = GCSE_SUBJECTS
      end
    end

    def set_grade_autocomplete_data
      qualification_type = @wizard.qualification_type_name
      if qualification_type.in? OTHER_UK_QUALIFICATIONS
        @grade_autocomplete_data = OTHER_UK_QUALIFICATION_GRADES
      end
    end
  end
end
