module CandidateInterface
  class CourseChoicesController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_not_amendable
    rescue_from ActiveRecord::RecordNotFound, with: :render_404

    def index
      @course_choices = current_candidate.current_application.application_choices
      if @course_choices.count < 1
        render :index
      else
        redirect_to candidate_interface_course_choices_review_path
      end
    end

    def have_you_chosen
      @choice_form = CandidateInterface::CourseChosenForm.new
    end

    def make_choice
      @choice_form = CandidateInterface::CourseChosenForm.new(application_choice_params)
      render :have_you_chosen and return unless @choice_form.valid?

      if @choice_form.chosen_a_course?
        redirect_to candidate_interface_course_choices_provider_path
      else
        redirect_to candidate_interface_go_to_find_path
      end
    end

    def go_to_find; end

    def options_for_provider
      @pick_provider = PickProviderForm.new
    end

    def pick_provider
      @pick_provider = PickProviderForm.new(
        provider_id: params.dig(:candidate_interface_pick_provider_form, :provider_id),
      )
      render :options_for_provider and return unless @pick_provider.valid?

      if @pick_provider.courses_available?
        redirect_to candidate_interface_course_choices_course_path(@pick_provider.provider_id)
      else
        redirect_to_ucas
      end
    end

    def ucas; end

    def options_for_course
      @pick_course = PickCourseForm.new(
        provider_id: params.fetch(:provider_id),
        application_form: current_application,
      )
    end

    def pick_course
      course_id = params.dig(:candidate_interface_pick_course_form, :course_id)
      @pick_course = PickCourseForm.new(
        provider_id: params.fetch(:provider_id),
        course_id: course_id,
        application_form: current_application,
      )
      render :options_for_course and return unless @pick_course.valid?

      if !@pick_course.open_on_apply?
        redirect_to_ucas
      elsif @pick_course.both_study_modes_available?
        redirect_to candidate_interface_course_choices_study_mode_path(
          @pick_course.provider_id,
          @pick_course.course_id,
        )
      elsif @pick_course.single_site?
        course_option = CourseOption.where(course_id: @pick_course.course.id).first
        pick_site_for_course(course_id, course_option.id)
      else
        redirect_to candidate_interface_course_choices_site_path(
          @pick_course.provider_id,
          @pick_course.course_id,
        )
      end
    end

    def options_for_study_mode
      @pick_study_mode = PickStudyModeForm.new(
        provider_id: params.fetch(:provider_id),
        course_id: params.fetch(:course_id),
      )
    end

    def pick_study_mode
      @pick_study_mode = PickStudyModeForm.new(
        provider_id: params.fetch(:provider_id),
        course_id: params.fetch(:course_id),
        study_mode: params.dig(
          :candidate_interface_pick_study_mode_form,
          :study_mode,
        ),
      )

      redirect_to candidate_interface_course_choices_site_path(
        @pick_study_mode.provider_id,
        @pick_study_mode.course_id,
        @pick_study_mode.study_mode,
      )
    end

    def options_for_site
      @pick_site = PickSiteForm.new(
        provider_id: params.fetch(:provider_id),
        course_id: params.fetch(:course_id),
        study_mode: params.fetch(:study_mode),
      )
    end

    def pick_site
      course_id = params.fetch(:course_id)
      course_option_id = params.dig(:candidate_interface_pick_site_form, :course_option_id)

      pick_site_for_course(course_id, course_option_id)
    end

    def review
      @application_form = current_application
      @course_choices = current_candidate.current_application.application_choices
    end

    def confirm_destroy
      @course_choice = current_candidate.current_application.application_choices.find(params[:id])
    end

    def destroy
      current_application
        .application_choices
        .find(current_course_choice_id)
        .destroy!

      current_application.update!(course_choices_completed: false)

      redirect_to candidate_interface_course_choices_index_path
    end

    def complete
      @application_form = current_application

      if @application_form.update(application_form_params)
        redirect_to candidate_interface_application_form_path
      else
        @course_choices = current_candidate.current_application.application_choices
        render :review
      end
    end

  private

    def current_course_choice_id
      params.permit(:id)[:id]
    end

    def application_form_params
      params.require(:application_form).permit(:course_choices_completed)
    end

    def application_choice_params
      params.fetch(:candidate_interface_course_chosen_form, {}).permit(:choice)
    end

    def pick_site_for_course(course_id, course_option_id)
      @pick_site = PickSiteForm.new(
        application_form: current_application,
        provider_id: params.fetch(:provider_id),
        course_id: course_id,
        course_option_id: course_option_id,
      )

      if @pick_site.save
        current_application.update!(course_choices_completed: false)

        redirect_to candidate_interface_course_choices_index_path
      else
        render :options_for_site
      end
    end

    def redirect_to_ucas
      redirect_to candidate_interface_course_choices_on_ucas_path
    end
  end
end
