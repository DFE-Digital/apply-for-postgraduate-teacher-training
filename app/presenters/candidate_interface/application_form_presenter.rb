module CandidateInterface
  class ApplicationFormPresenter
    def initialize(application_form)
      @application_form = application_form
    end

    def updated_at
      "Last saved on #{@application_form.updated_at.strftime('%d %B %Y')} at #{@application_form.updated_at.strftime('%H:%M %p')}"
    end

    def application_choices_added?
      @application_form.application_choices.present?
    end

    def personal_details_completed?
      CandidateInterface::PersonalDetailsForm.build_from_application(@application_form).valid?
    end

    def contact_details_completed?
      contact_details = CandidateInterface::ContactDetailsForm.build_from_application(@application_form)

      contact_details.valid?(:base) && contact_details.valid?(:address)
    end

    def work_experience_completed?
      @application_form.work_history_completed
    end

    def work_experience_path
      @application_form.application_work_experiences.any? ? Rails.application.routes.url_helpers.candidate_interface_work_history_show_path : Rails.application.routes.url_helpers.candidate_interface_work_history_length_path
    end

    def degrees_completed?
      @application_form.degrees_completed
    end

    def degrees_added?
      @application_form.application_qualifications.degrees.any?
    end

    def maths_gcse_completed?
      @application_form.maths_gcse.present?
    end

    def english_gcse_completed?
      @application_form.english_gcse.present?
    end

    def science_gcse_completed?
      @application_form.science_gcse.present?
    end

    def other_qualifications_completed?
      @application_form.other_qualifications_completed
    end

    def other_qualifications_added?
      @application_form.application_qualifications.other.any?
    end

    def becoming_a_teacher_completed?
      CandidateInterface::BecomingATeacherForm.build_from_application(@application_form).valid?
    end

    def subject_knowledge_completed?
      CandidateInterface::SubjectKnowledgeForm.build_from_application(@application_form).valid?
    end

    def interview_preferences_completed?
      CandidateInterface::InterviewPreferencesForm.build_from_application(@application_form).valid?
    end

    def course_choices_completed?
      @application_form.course_choices_completed
    end

    def volunteering_completed?
      @application_form.volunteering_completed
    end

    def volunteering_added?
      @application_form.application_volunteering_experiences.any?
    end

    def all_referees_provided_by_candidate?
      @application_form.references.count == ApplicationForm::MINIMUM_COMPLETE_REFERENCES
    end
  end
end
