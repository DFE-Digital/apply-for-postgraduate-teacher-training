module CandidateInterface
  class PersonalDetailsController < CandidateInterfaceController
    def edit
      @personal_details_form = PersonalDetailsForm.build_from_application(
        current_application,
      )
    end

    def update
      @personal_details_form = PersonalDetailsForm.new(personal_details_params)
      @personal_details_review = PersonalDetailsReviewPresenter.new(form: @personal_details_form)

      if @personal_details_form.save(current_application)
        render :show
      else
        render :edit
      end
    end

    def show
      personal_details_form = PersonalDetailsForm.build_from_application(
        current_application,
      )
      @personal_details_review = PersonalDetailsReviewPresenter.new(form: personal_details_form)
    end

  private

    def personal_details_params
      params.require(:candidate_interface_personal_details_form).permit(
        :first_name, :last_name,
        :"date_of_birth(3i)", :"date_of_birth(2i)", :"date_of_birth(1i)",
        :first_nationality, :second_nationality,
        :english_main_language,
        :english_language_details, :other_language_details
      )
        .transform_keys { |key| dob_field_to_attribute(key) }
        .transform_keys(&:strip)
    end

    def dob_field_to_attribute(key)
      case key
      when 'date_of_birth(3i)' then 'day'
      when 'date_of_birth(2i)' then 'month'
      when 'date_of_birth(1i)' then 'year'
      else key
      end
    end
  end
end
