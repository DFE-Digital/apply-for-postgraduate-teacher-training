module CandidateInterface
  module Degrees
    class SubjectController < CandidateInterfaceController
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
          redirect_to candidate_interface_degrees_review_path
        else
          render :edit
        end
      end

    private

      def degree
        @degree ||= ApplicationQualification.find(params[:id])
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
