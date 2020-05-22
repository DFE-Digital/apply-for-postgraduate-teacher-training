module CandidateInterface
  class PersonalStatement::SubjectKnowledgeController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted
    after_action :complete_section, only: %i[update]

    def edit
      @subject_knowledge_form = SubjectKnowledgeForm.build_from_application(
        current_application,
      )
      @course_names = chosen_course_names
    end

    def update
      @subject_knowledge_form = SubjectKnowledgeForm.new(subject_knowledge_params)

      if @subject_knowledge_form.save(current_application)
        current_application.update!(subject_knowledge_completed: false)

        redirect_to candidate_interface_subject_knowledge_show_path
      else
        track_validation_error(@subject_knowledge_form)
        @course_names = chosen_course_names
        render :edit
      end
    end

    def show
      @application_form = current_application
    end

    def complete
      current_application.update!(application_form_params)

      redirect_to candidate_interface_application_form_path
    end

  private

    def subject_knowledge_params
      params.require(:candidate_interface_subject_knowledge_form).permit(
        :subject_knowledge,
      )
        .transform_values(&:strip)
    end

    def chosen_course_names
      current_application.application_choices.map(&:course).map(&:name_and_code)
    end

    def application_form_params
      params.require(:application_form).permit(:subject_knowledge_completed)
        .transform_values(&:strip)
    end

    def complete_section
      presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)

      if presenter.subject_knowledge_completed? && !FeatureFlag.active?('mark_every_section_complete')
        current_application.update!(subject_knowledge_completed: true)
      end
    end
  end
end
