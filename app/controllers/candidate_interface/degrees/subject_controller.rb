module CandidateInterface
  module Degrees
    class SubjectController < CandidateInterfaceController
      before_action :redirect_to_dashboard_if_submitted
      before_action :set_subject_names

      def new
        @degree_subject_form = DegreeSubjectForm.new(degree: degree)
      end

      def create
        @degree_subject_form = DegreeSubjectForm.new(subject_params)
        if @degree_subject_form.save
          redirect_to candidate_interface_degree_institution_path(degree)
        else
          render :new
        end
      end

      def edit
        @degree_subject_form = DegreeSubjectForm.new(degree: degree).fill_form_values
      end

      def update
        @degree_subject_form = DegreeSubjectForm.new(subject_params)
        if @degree_subject_form.save
          current_application.update!(degrees_completed: false)
          redirect_to candidate_interface_degrees_review_path
        else
          track_validation_error(@degree_subject_form)
          render :edit
        end
      end

    private

      def degree
        @degree ||= ApplicationQualification.find(params[:id])
      end

      def set_subject_names
        @subjects = Hesa::Subject.names
      end

      def subject_params
        params
          .require(:candidate_interface_degree_subject_form)
          .permit(:subject)
          .merge(degree: degree)
      end
    end
  end
end
