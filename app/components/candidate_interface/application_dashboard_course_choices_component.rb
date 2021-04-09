module CandidateInterface
  class ApplicationDashboardCourseChoicesComponent < ViewComponent::Base
    include ViewHelper

    def initialize(
      application_form:,
      editable: true,
      heading_level: 2,
      show_status: false,
      show_incomplete: false,
      missing_error: false,
      application_choice_error: false,
      render_link_to_find_when_rejected_on_qualifications: false,
      display_accepted_application_choices: false
    )
      @application_form = application_form
      @editable = editable
      @heading_level = heading_level
      @show_status = show_status
      @show_incomplete = show_incomplete
      @missing_error = missing_error
      @application_choice_error = application_choice_error
      @render_link_to_find_when_rejected_on_qualifications = render_link_to_find_when_rejected_on_qualifications
      @display_accepted_application_choices = display_accepted_application_choices
    end

    def course_choice_rows(application_choice)
      [
        study_mode_row(application_choice),
        status_row(application_choice),
        rejection_reasons_row(application_choice),
        offer_withdrawal_reason_row(application_choice),
        interview_row(application_choice),
        withdraw_row(application_choice),
        respond_to_offer_row(application_choice),
      ].compact
    end

    def withdrawable?(application_choice)
      ApplicationStateChange.new(application_choice).can_withdraw?
    end

    def any_withdrawable?
      @application_form.application_choices.any? do |application_choice|
        withdrawable?(application_choice)
      end
    end

    def show_missing_banner?
      @show_incomplete && !@application_form.course_choices_completed && @editable
    end

    def course_change_path(application_choice)
      if has_multiple_courses?(application_choice)
        candidate_interface_course_choices_course_path(
          application_choice.provider.id,
          course_choice_id: application_choice.id,
        )
      end
    end

    def site_change_path(application_choice)
      if has_multiple_sites?(application_choice)
        candidate_interface_course_choices_site_path(
          application_choice.provider.id,
          application_choice.course.id,
          application_choice.offered_option.study_mode,
          course_choice_id: application_choice.id,
        )
      end
    end

    def container_class(application_choice)
      return unless @editable

      if application_choice.course_option_availability_error?
        "govuk-inset-text app-inset-text--narrow-border app-inset-text--#{@application_choice_error ? 'error' : 'important'}"
      end
    end

    def application_choices
      @application_choices ||= if @display_accepted_application_choices && application_choice_with_accepted_state_present?
                                 # Reject all applications that do not have an ACCEPTED_STATE
                                 # These will appear in the CandidateInterface::PreviousApplications component
                                 application_choices_with_accepted_states
                               else
                                 all_application_choices
                               end
    end

    def title_for(application_choice)
      "<span class=\"app-course-choice__provider-name\">#{application_choice.offered_course.provider.name}</span>
      <span class=\"app-course-choice__course-name\">#{application_choice.offered_course.name_and_code}</span>".html_safe
    end

  private

    attr_reader :application_form

    def study_mode_row(application_choice)
      return unless application_choice.course.full_time_or_part_time?

      change_path = candidate_interface_course_choices_study_mode_path(
        application_choice.provider.id,
        application_choice.course.id,
        course_choice_id: application_choice.id,
      )

      {
        key: 'Full time or part time',
        value: application_choice.offered_option.study_mode.humanize,
        action: "study mode for #{application_choice.course.name_and_code}",
        change_path: change_path,
      }
    end

    def interview_row(application_choice)
      return unless application_choice.interviews.kept.any? ||
        application_choice.awaiting_provider_decision?

      {
        key: 'Interview'.pluralize(application_choice.interviews.size),
        value: render(InterviewBookingsComponent.new(application_choice)),
      }
    end

    def status_row(application_choice)
      if @show_status
        {
          key: 'Status',
          value: render(ApplicationStatusTagComponent.new(application_choice: application_choice)),
        }
      end
    end

    def withdraw_row(application_choice)
      return nil unless withdrawable?(application_choice)

      {
        key: ' ',
        value: render(
          CandidateInterface::CourseChoicesSummaryCardActionComponent.new(
            action: :withdraw,
            application_choice: application_choice,
          ),
        ),
      }
    end

    def respond_to_offer_row(application_choice)
      return unless application_choice.offer?

      {
        key: ' ',
        value: render(
          CandidateInterface::CourseChoicesSummaryCardActionComponent.new(
            action: :respond_to_offer,
            application_choice: application_choice,
          ),
        ),
      }
    end

    def offer_withdrawal_reason_row(application_choice)
      if application_choice.offer_withdrawal_reason.present?
        {
          key: 'Reason for offer withdrawal',
          value: application_choice.offer_withdrawal_reason,
        }
      end
    end

    def rejection_reasons_row(application_choice)
      return nil unless application_choice.rejected?

      if application_choice.structured_rejection_reasons.present?
        {
          key: 'Feedback',
          value: render(
            ReasonsForRejectionComponent.new(
              application_choice: application_choice,
              reasons_for_rejection: ReasonsForRejection.new(application_choice.structured_rejection_reasons),
              editable: false,
              render_link_to_find_when_rejected_on_qualifications: @render_link_to_find_when_rejected_on_qualifications,
            ),
          ),
        }
      elsif application_choice.rejection_reason.present?
        {
          key: 'Feedback',
          value: application_choice.rejection_reason,
        }
      end
    end

    def has_multiple_sites?(application_choice)
      CourseOption.where(course_id: application_choice.course.id, study_mode: application_choice.offered_option.study_mode).many?
    end

    def has_multiple_courses?(application_choice)
      Course.current_cycle.where(provider: application_choice.provider).many?
    end

    def application_choices_with_accepted_states
      @application_form
        .application_choices
        .includes(:course, :site, :provider, :offered_course_option, :interviews)
        .order(id: :asc)
        .select { |ac| ac.status.to_sym.in?(ApplicationStateChange::ACCEPTED_STATES) }
    end

    def all_application_choices
      @application_form
        .application_choices
        .includes(:course, :site, :provider, :offered_course_option, :interviews)
        .order(id: :asc)
    end

    def application_choice_with_accepted_state_present?
      @application_form.application_choices.any? { |ac| ApplicationStateChange::ACCEPTED_STATES.include?(ac.status.to_sym) }
    end
  end
end
