module CandidateInterface
  class FindCourseSelectionsController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_not_amendable
    rescue_from ActiveRecord::RecordNotFound, with: :render_404

    def confirm_selection
      course = Course.find(params[:course_id])
      @course_selection_form = CourseSelectionForm.new(course)
    end

    def complete_selection
      course = Course.find(params[:course_id])

      # TODO: refactor this into a service etc.?
      if CourseOption.where(course_id: course.id).one?
        course_option = CourseOption.where(course_id: @pick_course.course.id).first

        pick_site_for_course(course_code, course_option.id)
      else
        redirect_to candidate_interface_course_choices_site_path(
          provider_code: course.provider.code,
          course_code: course.code,
        )
      end
    end

  private

    def pick_site_for_course(course_code, course_option_id)
      @pick_site = PickSiteForm.new(
        application_form: current_application,
        provider_code: params.fetch(:provider_code),
        course_code: course_code,
        course_option_id: course_option_id,
      )

      if @pick_site.save
        redirect_to candidate_interface_course_choices_index_path
      else
        render :options_for_site
      end
    end
  end
end
