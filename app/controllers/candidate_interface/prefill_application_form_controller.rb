module CandidateInterface
  class PrefillApplicationFormController < CandidateInterfaceController
    def new
      @prefill_application_or_not_form = PrefillApplicationOrNotForm.new
    end

    def create
      @prefill_application_or_not_form = PrefillApplicationOrNotForm.new(prefill_application_or_not_params)
      render :new and return unless @prefill_application_or_not_form.valid?

      if @prefill_application_or_not_form.prefill?
        prefill_candidate_application_form
        flash[:info] = 'This application has been prefilled with example data'
        redirect_to candidate_interface_application_form_path
      else
        redirect_to candidate_interface_before_you_start_path
      end
    end

    def prefill_candidate_application_form
      example_application_choices = TestApplications.new.create_application(
        recruitment_cycle_year: RecruitmentCycle.current_year,
        states: [:unsubmitted_with_completed_references],
        courses_to_apply_to: Course.includes(:course_options).joins(:course_options).distinct.open_on_apply,
        candidate: current_candidate,
      )
      example_application_form = example_application_choices.first.application_form
      current_candidate.application_forms << example_application_form
    end

  private

    def prefill_application_or_not_params
      params.fetch(:candidate_interface_prefill_application_or_not_form, {}).permit(:prefill)
    end
  end
end
