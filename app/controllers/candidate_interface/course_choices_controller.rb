module CandidateInterface
  class CourseChoicesController < CandidateInterfaceController
    def index
      @application_form = current_application
      @course_choices = current_candidate.current_application.application_choices
      @page_title = if @course_choices.count < 1
                      t('page_titles.choosing_courses')
                    else
                      t('page_titles.course_choices')
                    end
    end

    def have_you_chosen
      @choice = current_candidate.current_application.application_choices.new
    end

    def make_choice
      if application_choice_params[:choice] == 'yes'
        redirect_to candidate_interface_course_choices_provider_path
      else
        redirect_to 'https://find-postgraduate-teacher-training.education.gov.uk'
      end
    end

    def options_for_provider
      # TODO: Remove when the QA environment no longer has the "Example provider" stored
      @providers = Provider.where.not(name: 'Example provider')
    end

    def pick_provider
      if provider_params[:code] == 'other'
        redirect_to candidate_interface_course_choices_on_ucas_path
      else
        redirect_to candidate_interface_course_choices_course_path(provider_code: provider_params[:code])
      end
    end

    def ucas; end

    def options_for_course
      @courses = Provider
        .find_by(code: params[:provider_code])
        .courses
        .where(exposed_in_find: true)
    end

    def pick_course
      if course_params[:code] == 'other'
        redirect_to candidate_interface_course_choices_on_ucas_path
      else
        redirect_to candidate_interface_course_choices_site_path(provider_code: params[:provider_code], course_code: course_params[:code])
      end
    end

    def options_for_site
      provider = Provider.find_by(code: params[:provider_code])
      course = provider.courses.find_by(code: params[:course_code])
      @options = CourseOption.where(course_id: course.id)
    end

    def pick_site
      # TODO: add better validation
      redirect_back(fallback_location: root_path) && return unless params[:course_option]

      @application_form = current_application
      @course_choices = @application_form.application_choices
      selected_courses = @course_choices.map(&:course)

      if selected_courses.include?(Course.find_by(code: params[:course_code]))
        @application_form.errors[:base] << 'You have already selected this course'
        render :index
      else
        @course_choices.create!(
          course_option: CourseOption.find(course_option_params[:id]),
        )
        redirect_to candidate_interface_course_choices_index_path
      end
    end

    def confirm_destroy
      @course_choice = current_candidate.current_application.application_choices.find(params[:id])
    end

    def destroy
      current_application
        .application_choices
        .find(current_course_choice_id)
        .destroy!

      redirect_to candidate_interface_course_choices_index_path
    end

    def complete
      @application_form = current_application
      @application_form.course_choices_present = true

      if @application_form.update(application_form_params)
        redirect_to candidate_interface_application_form_path
      else
        @course_choices = current_candidate.current_application.application_choices
        render :index
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
      params.require(:application_choice).permit(:choice)
    end

    def provider_params
      params.require(:provider).permit(:code)
    end

    def course_params
      params.require(:course).permit(:code)
    end

    def course_option_params
      params.require(:course_option).permit(:id)
    end
  end
end
