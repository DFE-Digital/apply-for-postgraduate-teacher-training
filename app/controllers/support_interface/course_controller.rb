module SupportInterface
  class CourseController < SupportInterfaceController
    def show
      @course = Course.find(params[:course_id])
    end

    def applications
      @course = Course.find(params[:course_id])
    end

    def vacancies
      @course = Course.find(params[:course_id])
      @course_options = CourseOption.where(course: @course).includes(:site, :course)
    end

    def update
      @course = Course.find(params[:course_id])

      if @course.update(params.require(:course).permit(:open_on_apply))
        flash[:success] = 'Successfully updated course'
        redirect_to support_interface_course_path(@course)
      else
        render :show
      end
    end
  end
end
