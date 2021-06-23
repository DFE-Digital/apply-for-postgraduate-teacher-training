# Detect state that *should* be impossible in the system and report them to Sentry
class DetectInvariants
  include Sidekiq::Worker

  def perform
    detect_application_choices_in_old_states
    detect_outstanding_references_on_submitted_applications
    detect_unauthorised_application_form_edits
    detect_applications_with_course_choices_in_previous_cycle
    detect_submitted_applications_with_more_than_three_course_choices
    detect_applications_submitted_with_the_same_course
    detect_course_sync_not_succeeded_for_an_hour
    detect_high_sidekiq_retries_queue_length
    detect_application_choices_with_courses_from_the_incorrect_cycle
    detect_submitted_applications_with_more_than_two_selected_references
  end

  def detect_application_choices_in_old_states
    choices_in_wrong_state = begin
      ApplicationChoice
        .where("status IN ('awaiting_references', 'application_complete')")
        .map(&:id).sort
    end

    if choices_in_wrong_state.any?
      urls = choices_in_wrong_state.map { |application_choice_id| helpers.support_interface_application_choice_url(application_choice_id) }

      message = <<~MSG
        One or more application choices are still in `awaiting_references` or
        `application_complete` state, but all these states have been removed:

        #{urls.join("\n")}
      MSG

      Raven.capture_exception(ApplicationInRemovedState.new(message))
    end
  end

  def detect_outstanding_references_on_submitted_applications
    applications_with_reference_weirdness = ApplicationChoice
      .joins(application_form: [:application_references])
      .where.not(application_choices: { status: 'unsubmitted' })
      .where(references: { feedback_status: :feedback_requested })
      .pluck(:application_form_id).uniq
      .sort

    if applications_with_reference_weirdness.any?
      urls = applications_with_reference_weirdness.map { |application_form_id| helpers.support_interface_application_form_url(application_form_id) }

      message = <<~MSG
        One or more references are still pending on these applications,
        even though they've already been submitted:

        #{urls.join("\n")}
      MSG

      Raven.capture_exception(OutstandingReferencesOnSubmittedApplication.new(message))
    end
  end

  def detect_unauthorised_application_form_edits
    unauthorised_changes = Audited::Audit
      .joins("INNER JOIN application_forms ON audits.associated_type = 'ApplicationForm' AND application_forms.id = audits.associated_id")
      .joins('INNER JOIN candidates ON candidates.id = application_forms.candidate_id')
      .where(user_type: 'Candidate')
      .where('candidates.id != audits.user_id')
      .pluck('application_forms.id').uniq
      .sort

    if unauthorised_changes.any?
      urls = unauthorised_changes.map { |application_form_id| helpers.support_interface_application_form_url(application_form_id) }

      message = <<~MSG
        The following application forms have had edits by a candidate who is not the owner of the application:

        #{urls.join("\n")}
      MSG

      Raven.capture_exception(ApplicationEditedByWrongCandidate.new(message))
    end
  end

  def detect_applications_with_course_choices_in_previous_cycle
    forms_with_last_years_courses = ApplicationChoice
      .joins(:application_form, course_option: [:course])
      .where('extract(year from application_forms.submitted_at) = ?', RecruitmentCycle.current_year)
      .where(courses: { recruitment_cycle_year: RecruitmentCycle.previous_year })
      .pluck(:application_form_id).uniq
      .sort

    if forms_with_last_years_courses.any?
      urls = forms_with_last_years_courses.map { |application_form_id| helpers.support_interface_application_form_url(application_form_id) }

      message = <<~MSG
        The following application forms have course choices from the previous recruitment cycle

        #{urls.join("\n")}
      MSG

      Raven.capture_exception(ApplicationHasCourseChoiceInPreviousCycle.new(message))
    end
  end

  def detect_submitted_applications_with_more_than_three_course_choices
    applications_with_too_many_choices = ApplicationForm
      .joins(:application_choices)
      .where(application_choices: { status: (ApplicationStateChange::DECISION_PENDING_STATUSES + ApplicationStateChange::ACCEPTED_STATES) })
      .group('application_forms.id')
      .having('count(application_choices) > 3')
      .sort

    if applications_with_too_many_choices.any?
      urls = applications_with_too_many_choices.map { |application_form_id| helpers.support_interface_application_form_url(application_form_id) }

      message = <<~MSG
        The following application forms have been submitted with more than three course choices

        #{urls.join("\n")}
      MSG

      Raven.capture_exception(SubmittedApplicationHasMoreThanThreeChoices.new(message))
    end
  end

  def detect_applications_submitted_with_the_same_course
    applications_with_the_same_choice = ApplicationForm
      .joins(application_choices: [:course_option])
      .where.not(submitted_at: nil)
      .where.not("application_choices.status": %w[withdrawn rejected])
      .group('application_forms.id', 'course_options.course_id')
      .having('COUNT(DISTINCT course_options.course_id) < COUNT(application_choices.id)')

    if applications_with_the_same_choice.any?
      urls = applications_with_the_same_choice.map { |application_form_id| helpers.support_interface_application_form_url(application_form_id) }

      message = <<~MSG
        The following applications have been submitted containing the same course choice multiple times

        #{urls.join("\n")}
      MSG

      Raven.capture_exception(ApplicationSubmittedWithTheSameCourse.new(message))
    end
  end

  def detect_course_sync_not_succeeded_for_an_hour
    unless TeacherTrainingPublicAPI::SyncCheck.check
      Raven.capture_exception(
        CourseSyncNotSucceededForAnHour.new(
          'The course sync via the Teacher training public API has not succeeded for an hour',
        ),
      )
    end
  end

  def detect_high_sidekiq_retries_queue_length
    retries_queue_length = Sidekiq::RetrySet.new.size
    if retries_queue_length > 50
      Raven.capture_exception(
        SidekiqRetriesQueueHigh.new(
          "Sidekiq pending retries depth is high (#{retries_queue_length}). Suggests high error rate",
        ),
      )
    end
  end

  def detect_application_choices_with_courses_from_the_incorrect_cycle
    applications_choices_with_invalid_courses = ApplicationChoice
    .joins(:application_form, current_course_option: [:course])
    .where('courses.recruitment_cycle_year != application_forms.recruitment_cycle_year')
    .where(offer_deferred_at: nil)

    if applications_choices_with_invalid_courses.any?
      urls = applications_choices_with_invalid_courses
      .map(&:application_form)
      .uniq
      .map { |application_form| helpers.support_interface_application_form_url(application_form.id) }

      message = <<~MSG
        The following applications have an application choice with a course from a different recruitment cycle

        #{urls.join("\n")}
      MSG

      Raven.capture_exception(ApplicationWithADifferentCyclesCourse.new(message))
    end
  end

  def detect_submitted_applications_with_more_than_two_selected_references
    applications_with_more_than_two_selected_references = ApplicationForm
    .joins(:application_references)
    .where.not(submitted_at: nil)
    .where(references: { selected: true })
    .group('references.application_form_id')
    .having('COUNT("references".id) > 2')
    .pluck(:application_form_id).uniq
    .sort

    if applications_with_more_than_two_selected_references.any?
      urls = applications_with_more_than_two_selected_references.map { |application_form_id| helpers.support_interface_application_form_url(application_form_id) }

      message = <<~MSG
        The following applications have been submitted with more than two selected references

        #{urls.join("\n")}
      MSG

      Raven.capture_exception(ApplicationSubmittedWithMoreThanTwoSelectedReferences.new(message))
    end
  end

  class ApplicationInRemovedState < StandardError; end
  class OutstandingReferencesOnSubmittedApplication < StandardError; end
  class ApplicationEditedByWrongCandidate < StandardError; end
  class ApplicationHasCourseChoiceInPreviousCycle < StandardError; end
  class SubmittedApplicationHasMoreThanThreeChoices < StandardError; end
  class ApplicationSubmittedWithTheSameCourse < StandardError; end
  class CourseSyncNotSucceededForAnHour < StandardError; end
  class SidekiqRetriesQueueHigh < StandardError; end
  class ApplicationWithADifferentCyclesCourse < StandardError; end
  class ApplicationSubmittedWithMoreThanTwoSelectedReferences < StandardError; end

private

  def helpers
    Rails.application.routes.url_helpers
  end
end
