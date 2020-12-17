class CandidateMailerPreview < ActionMailer::Preview
  def application_submitted
    application_form = FactoryBot.build_stubbed(
      :completed_application_form,
      candidate: candidate,
      support_reference: 'ABCDEF',
    )

    CandidateMailer.application_submitted(application_form)
  end

  def application_submitted_apply_again
    application_form = FactoryBot.build_stubbed(
      :completed_application_form,
      candidate: candidate,
      support_reference: 'ABCDEF',
      application_choices: [FactoryBot.build_stubbed(:application_choice, :awaiting_provider_decision, course_option: course_option)],
    )

    CandidateMailer.application_submitted_apply_again(application_form)
  end

  def changed_offer
    application_form = application_form_with_course_choices([application_choice_with_offer, application_choice_with_offer])
    application_choice = FactoryBot.build_stubbed(
      :submitted_application_choice,
      course_option: course_option,
      application_form: application_form,
      offered_course_option: course_option,
      decline_by_default_at: 10.business_days.from_now,
    )

    CandidateMailer.changed_offer(application_choice)
  end

  def chase_reference
    CandidateMailer.chase_reference(reference)
  end

  def chase_reference_again
    CandidateMailer.chase_reference_again(reference)
  end

  def new_referee_request
    CandidateMailer.new_referee_request(reference, reason: :not_responded)
  end

  def new_referee_request_with_refused
    CandidateMailer.new_referee_request(reference, reason: :refused)
  end

  def new_referee_request_with_email_bounced
    CandidateMailer.new_referee_request(reference, reason: :email_bounced)
  end

  def chase_candidate_decision_with_one_offer
    application_form = application_form_with_course_choices([application_choice_with_offer])

    CandidateMailer.chase_candidate_decision(application_form)
  end

  def chase_candidate_decision_with_multiple_offers
    application_choices =
      [
        application_choice_with_offer,
        application_choice_with_offer,
        application_choice_with_offer,
      ]
    application_form = application_form_with_course_choices(application_choices)
    CandidateMailer.chase_candidate_decision(application_form)
  end

  def new_offer_single_offer
    application_choice = application_form.application_choices.build(
      course_option: course_option,
      status: :offer,
      offer: { conditions: ['DBS check', 'Pass exams'] },
      offered_at: Time.zone.now,
      offered_course_option: course_option,
      decline_by_default_at: 10.business_days.from_now,
    )
    CandidateMailer.new_offer_single_offer(application_choice)
  end

  def new_offer_multiple_offers
    course_option = FactoryBot.build_stubbed(:course_option, site: site)
    application_choice = application_form.application_choices.build(
      course_option: course_option,
      status: :offer,
      offer: { conditions: ['DBS check', 'Pass exams'] },
      offered_at: Time.zone.now,
      offered_course_option: course_option,
      decline_by_default_at: 10.business_days.from_now,
    )
    other_course_option = FactoryBot.build_stubbed(:course_option, site: site)
    application_form.application_choices.build(
      course_option: other_course_option,
      status: :offer,
      offer: { conditions: ['Get a degree'] },
      offered_at: Time.zone.now,
      offered_course_option: other_course_option,
      decline_by_default_at: 7.business_days.from_now,
    )
    CandidateMailer.new_offer_multiple_offers(application_choice)
  end

  def new_offer_decisions_pending
    course_option = FactoryBot.build_stubbed(:course_option, site: site)
    application_choice = application_form.application_choices.build(
      course_option: course_option,
      status: :offer,
      offer: { conditions: ['DBS check', 'Pass exams'] },
      offered_at: Time.zone.now,
      offered_course_option: course_option,
      decline_by_default_at: 10.business_days.from_now,
    )
    other_course_option = FactoryBot.build_stubbed(:course_option, site: site)
    application_form.application_choices.build(
      course_option: other_course_option,
      status: :awaiting_provider_decision,
    )
    CandidateMailer.new_offer_decisions_pending(application_choice)
  end

  def application_rejected_all_rejected
    application_form = FactoryBot.build_stubbed(:application_form, candidate: candidate, first_name: 'Tyrell', last_name: 'Wellick')
    application_choice = FactoryBot.build_stubbed(:application_choice,
                                                  course_option: course_option,
                                                  application_form: application_form,
                                                  rejection_reason: 'Not enough experience.')

    CandidateMailer.application_rejected_all_rejected(application_choice)
  end

  def application_rejected_by_default_all_rejected
    application_form = FactoryBot.build_stubbed(:application_form, candidate: candidate, first_name: 'Tyrell', last_name: 'Wellick')
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      course_option: course_option,
      application_form: application_form,
      rejected_by_default: true,
      reject_by_default_at: 2.days.ago,
    )

    CandidateMailer.application_rejected_all_rejected(application_choice)
  end

  def application_rejected_awaiting_decisions
    application_form = FactoryBot.build_stubbed(:application_form,
                                                first_name: 'Tyrell',
                                                last_name: 'Wellick',
                                                application_choices: [
                                                  FactoryBot.build_stubbed(:application_choice, status: :awaiting_provider_decision, course_option: course_option),
                                                  FactoryBot.build_stubbed(:application_choice,
                                                                           course_option: course_option,
                                                                           status: :rejected,
                                                                           rejection_reason: 'Not enough experience.'),
                                                ])

    CandidateMailer.application_rejected_awaiting_decisions(application_form.application_choices.last)
  end

  def application_rejected_by_default_awaiting_decisions
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Tyrell',
      last_name: 'Wellick',
      application_choices: [
        FactoryBot.build_stubbed(
          :application_choice,
          status: :awaiting_provider_decision,
          course_option: course_option,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          course_option: course_option,
          status: :rejected,
          rejected_by_default: true,
          reject_by_default_at: 2.days.ago,
        ),
      ],
    )

    CandidateMailer.application_rejected_awaiting_decisions(application_form.application_choices.last)
  end

  def application_rejected_offers_made
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Tyrell',
      last_name: 'Wellick',
      candidate: candidate,
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, :with_offer, decline_by_default_days: 10, course_option: course_option),
        FactoryBot.build_stubbed(:application_choice, :with_offer, decline_by_default_days: 10, course_option: course_option),
        FactoryBot.build_stubbed(:application_choice,
                                 course_option: course_option,
                                 decline_by_default_days: 10,
                                 rejection_reason: 'Not enough experience.'),
      ],
    )

    CandidateMailer.application_rejected_offers_made(application_form.application_choices.last)
  end

  def application_rejected_by_default_offers_made
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Tyrell',
      last_name: 'Wellick',
      candidate: candidate,
      application_choices: [
        FactoryBot.build_stubbed(
          :application_choice,
          :with_offer,
          decline_by_default_days: 10,
          course_option: course_option,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          :with_offer,
          decline_by_default_days: 10,
          course_option: course_option,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          course_option: course_option,
          decline_by_default_days: 10,
          rejected_by_default: true,
          reject_by_default_at: 2.days.ago,
        ),
      ],
    )

    CandidateMailer.application_rejected_offers_made(application_form.application_choices.last)
  end

  def all_applications_rejected
    reasons_for_rejection = {
      candidate_behaviour_y_n: 'Yes',
      candidate_behaviour_what_did_the_candidate_do: %w[other],
      candidate_behaviour_other: 'Bad language',
      candidate_behaviour_what_to_improve: 'Do not swear',
      quality_of_application_y_n: 'Yes',
      quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge],
      quality_of_application_personal_statement_what_to_improve: 'Do not refer to yourself in the third person',
    }
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      :with_rejection_by_default_and_feedback,
      application_form: application_form,
      course_option: course_option,
      structured_rejection_reasons: reasons_for_rejection,
    )
    CandidateMailer.all_applications_rejected(application_choice)
  end

  def application_rejected__one_offer_one_awaiting_decision
    reasons_for_rejection = {
      candidate_behaviour_y_n: 'Yes',
      candidate_behaviour_what_did_the_candidate_do: %w[other],
      candidate_behaviour_other: 'Bad language',
      candidate_behaviour_what_to_improve: 'Do not swear',
      quality_of_application_y_n: 'Yes',
      quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge],
      quality_of_application_personal_statement_what_to_improve: 'Do not refer to yourself in the third person',
    }

    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Tyrell',
      last_name: 'Wellick',
      candidate: candidate,
      application_choices: [
        FactoryBot.build_stubbed(
          :application_choice,
          application_form: application_form,
          course_option: course_option,
          status: :rejected,
          structured_rejection_reasons: reasons_for_rejection,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          :with_offer,
          application_form: application_form,
          decline_by_default_days: 10,
          course_option: course_option,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          application_form: application_form,
          decline_by_default_at: 2.days.from_now,
          status: :awaiting_provider_decision,
          course_option: course_option,
        ),
      ],
    )
    CandidateMailer.application_rejected__one_offer_one_awaiting_decision(application_form.application_choices.first)
  end

  def application_rejected__awaiting_decision_only
    reasons_for_rejection = {
      candidate_behaviour_y_n: 'Yes',
      candidate_behaviour_what_did_the_candidate_do: %w[other],
      candidate_behaviour_other: 'Bad language',
      candidate_behaviour_what_to_improve: 'Do not swear',
      quality_of_application_y_n: 'Yes',
      quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge],
      quality_of_application_personal_statement_what_to_improve: 'Do not refer to yourself in the third person',
    }

    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Tyrell',
      last_name: 'Wellick',
      candidate: candidate,
      application_choices: [
        FactoryBot.build_stubbed(
          :application_choice,
          application_form: application_form,
          course_option: course_option,
          status: :rejected,
          structured_rejection_reasons: reasons_for_rejection,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          status: :awaiting_provider_decision,
          application_form: application_form,
          decline_by_default_at: 3.days.from_now,
          course_option: course_option,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          application_form: application_form,
          decline_by_default_at: 2.days.from_now,
          status: :awaiting_provider_decision,
          course_option: course_option,
        ),
      ],
    )
    CandidateMailer.application_rejected__awaiting_decision_only(application_form.application_choices.first)
  end

  def application_rejected__offers_only
    reasons_for_rejection = {
      candidate_behaviour_y_n: 'Yes',
      candidate_behaviour_what_did_the_candidate_do: %w[other],
      candidate_behaviour_other: 'Bad language',
      candidate_behaviour_what_to_improve: 'Do not swear',
      quality_of_application_y_n: 'Yes',
      quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge],
      quality_of_application_personal_statement_what_to_improve: 'Do not refer to yourself in the third person',
    }

    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Tyrell',
      last_name: 'Wellick',
      candidate: candidate,
      application_choices: [
        FactoryBot.build_stubbed(
          :application_choice,
          application_form: application_form,
          course_option: course_option,
          status: :rejected,
          structured_rejection_reasons: reasons_for_rejection,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          :with_offer,
          application_form: application_form,
          decline_by_default_at: 3.days.from_now,
          course_option: course_option,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          :with_offer,
          application_form: application_form,
          decline_by_default_at: 2.days.from_now,
          course_option: course_option,
        ),
      ],
    )
    CandidateMailer.application_rejected__offers_only(application_form.application_choices.first)
  end

  def feedback_received_for_application_rejected_by_default
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      :with_rejection_by_default_and_feedback,
      application_form: application_form,
      course_option: course_option,
    )
    CandidateMailer.feedback_received_for_application_rejected_by_default(application_choice)
  end

  def reference_received
    CandidateMailer.reference_received(reference)
  end

  def declined_by_default_multiple_offers
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'declined', declined_by_default: true, course_option: course_option),
        FactoryBot.build_stubbed(:application_choice, status: 'declined', declined_by_default: true, course_option: course_option),
        FactoryBot.build_stubbed(:application_choice, status: 'awaiting_provider_decision', declined_by_default: false, course_option: course_option),
      ],
      candidate: candidate,
    )

    CandidateMailer.declined_by_default(application_form)
  end

  def declined_by_default_only_one_offer
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'declined', declined_by_default: true, course_option: course_option),
        FactoryBot.build_stubbed(:application_choice, status: 'awaiting_provider_decision', declined_by_default: false, course_option: course_option),
      ],
    )

    CandidateMailer.declined_by_default(application_form)
  end

  def declined_by_default_with_rejections
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'declined', declined_by_default: true, course_option: course_option),
        FactoryBot.build_stubbed(:application_choice, status: 'rejected', declined_by_default: false, course_option: course_option),
      ],
      candidate: candidate,
    )

    CandidateMailer.declined_by_default(application_form)
  end

  def declined_by_default_without_rejections
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'declined', declined_by_default: true, course_option: course_option),
        FactoryBot.build_stubbed(:application_choice, status: 'declined', declined_by_default: true, course_option: course_option),
      ],
      candidate: candidate,
    )

    CandidateMailer.declined_by_default(application_form)
  end

  def decline_last_application_choice
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'declined', course_option: course_option),
      ],
      candidate: candidate,
    )

    CandidateMailer.decline_last_application_choice(application_form.application_choices.first)
  end

  def withdraw_last_application_choice
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'withdrawn', course_option: course_option),
      ],
      candidate: candidate,
    )

    CandidateMailer.withdraw_last_application_choice(application_form)
  end

  def conditions_met
    CandidateMailer.conditions_met(application_choice_with_offer)
  end

  def conditions_not_met
    CandidateMailer.conditions_not_met(application_choice_with_offer)
  end

  def apply_again_call_to_action
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Bob',
      candidate: candidate,
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'rejected', course_option: course_option),
      ],
    )

    CandidateMailer.apply_again_call_to_action(application_form)
  end

  def deferred_offer
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'pending_conditions', course_option: course_option),
      ],
      candidate: candidate,
    )

    CandidateMailer.deferred_offer(application_form.application_choices.first)
  end

  def deferred_offer_reminder
    course_option = FactoryBot.build_stubbed(
      :course_option,
      course: FactoryBot.build_stubbed(
        :course,
        recruitment_cycle_year: RecruitmentCycle.previous_year,
      ),
    )

    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      :with_deferred_offer,
      course_option: course_option,
      offered_course_option: course_option,
      application_form: application_form,
      decline_by_default_at: 10.business_days.from_now,
      offer_deferred_at: Time.zone.local(2020, 2, 3),
    )

    CandidateMailer.deferred_offer_reminder(application_choice)
  end

  def reinstated_offer_with_conditions
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      :with_accepted_offer,
      application_form: application_form,
      course_option: course_option,
      offer_deferred_at: Time.zone.local(2019, 10, 14),
    )
    CandidateMailer.reinstated_offer(application_choice)
  end

  def reinstated_offer_without_condidtions
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      :with_recruited,
      application_form: application_form,
      course_option: course_option,
      offer: { 'conditions' => [] },
      offer_deferred_at: Time.zone.local(2019, 10, 14),
    )
    CandidateMailer.reinstated_offer(application_choice)
  end

  def ucas_match_initial_email_duplicate_applications
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      application_form: application_form,
      course_option: course_option,
    )

    CandidateMailer.ucas_match_initial_email_duplicate_applications(application_choice)
  end

  def ucas_match_initial_email_multiple_acceptances
    candidate = FactoryBot.build_stubbed(:candidate, application_forms: [application_form])

    CandidateMailer.ucas_match_initial_email_multiple_acceptances(candidate)
  end

  def ucas_match_reminder_email_duplicate_applications
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      application_form: application_form,
      course_option: course_option,
    )
    ucas_match = FactoryBot.build_stubbed(
      :ucas_match,
      application_form: application_choice.application_form,
      action_taken: 'initial_emails_sent',
      candidate_last_contacted_at: Time.zone.local(2019, 10, 14),
    )

    CandidateMailer.ucas_match_reminder_email_duplicate_applications(application_choice, ucas_match)
  end

  def ucas_match_reminder_email_multiple_acceptances
    ucas_match = FactoryBot.build_stubbed(
      :ucas_match,
      action_taken: 'initial_emails_sent',
      candidate_last_contacted_at: Time.zone.local(2019, 10, 14),
    )

    CandidateMailer.ucas_match_reminder_email_multiple_acceptances(ucas_match)
  end

private

  def candidate
    candidate = FactoryBot.build_stubbed(:candidate)

    # This is not great. It's necessary because some of our mail templates
    # generates and send a new magic link token to candidates.
    def candidate.update!(*)
      true
    end

    candidate
  end

  def application_form
    @application_form ||= FactoryBot.build_stubbed(:application_form, first_name: 'Gemma', candidate: candidate)
  end

  def reference
    FactoryBot.build_stubbed(:reference, application_form: application_form)
  end

  def application_form_with_course_choices(course_choices)
    FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Tyrell',
      last_name: 'Wellick',
      application_choices: course_choices,
      candidate: candidate,
    )
  end

  def provider
    FactoryBot.build_stubbed(:provider)
  end

  def course
    FactoryBot.build_stubbed(:course, provider: provider)
  end

  def site
    @site ||= FactoryBot.build_stubbed(:site, code: '-', name: 'Main site')
  end

  def course_option
    FactoryBot.build_stubbed(:course_option, course: course, site: site)
  end

  def application_choice_with_offer
    FactoryBot.build_stubbed(:application_choice, :with_offer,
                             course_option: course_option,
                             decline_by_default_at: Time.zone.now,
                             sent_to_provider_at: 1.day.ago)
  end
end
