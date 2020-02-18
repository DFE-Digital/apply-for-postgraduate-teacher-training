class CandidateMailerPreview < ActionMailer::Preview
  def application_submitted
    application_form = FactoryBot.build_stubbed(
      :completed_application_form,
      support_reference: 'ABC-DEF',
    )

    CandidateMailer.application_submitted(application_form)
  end

  def application_sent_to_provider
    application_form = FactoryBot.build_stubbed(
      :completed_application_form,
      application_choices: [FactoryBot.build_stubbed(:application_choice, :awaiting_provider_decision)],
    )

    CandidateMailer.application_sent_to_provider(application_form)
  end

  def chase_reference
    CandidateMailer.chase_reference(reference)
  end

  def survey_email
    CandidateMailer.survey_email(application_form)
  end

  def survey_chaser_email
    CandidateMailer.survey_chaser_email(application_form)
  end

  def new_referee_request_with_not_responded
    CandidateMailer.new_referee_request(reference, reason: :not_responded)
  end

  def new_referee_request_with_refused
    CandidateMailer.new_referee_request(reference, reason: :refused)
  end

  def new_referee_request_with_email_bounced
    CandidateMailer.new_referee_request(reference, reason: :email_bounced)
  end

  def chase_candidate_decision_with_one_offer
    application_choice = OpenStruct.new(
      provider: OpenStruct.new(name: 'Provider Name'),
      decline_by_default_at: Time.zone.now,
      application_form: application_form,
      course: OpenStruct.new(name: 'Course Name'),
    )

    CandidateMailer.chase_candidate_decision(application_form_with_chooices([application_choice]))
  end

  def chase_candidate_decision_with_multiple_offers
    application_choice = OpenStruct.new(
      provider: OpenStruct.new(name: 'Wen University'),
      decline_by_default_at: Time.zone.now,
      application_form: application_form,
      course: OpenStruct.new(name: 'Math with Dance'),
    )

    application_choice_two = OpenStruct.new(
      provider: OpenStruct.new(name: 'Ting University'),
      decline_by_default_at: Time.zone.now,
      application_form: application_form,
      course: OpenStruct.new(name: 'Dance'),
    )

    application_choice_three = OpenStruct.new(
      provider: OpenStruct.new(name: 'Wang College'),
      decline_by_default_at: Time.zone.now,
      application_form: application_form,
      course: OpenStruct.new(name: 'Moar Dance'),
    )

    CandidateMailer.chase_candidate_decision(application_form_with_chooices(
                                               [application_choice, application_choice_two, application_choice_three],
))
  end

  def new_offer_single_offer
    course_option = FactoryBot.build_stubbed(:course_option)
    application_choice = application_form.application_choices.build(
      id: 123,
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
    course_option = FactoryBot.build_stubbed(:course_option)
    application_choice = application_form.application_choices.build(
      id: 123,
      course_option: course_option,
      status: :offer,
      offer: { conditions: ['DBS check', 'Pass exams'] },
      offered_at: Time.zone.now,
      offered_course_option: course_option,
      decline_by_default_at: 10.business_days.from_now,
    )
    other_course_option = FactoryBot.build_stubbed(:course_option)
    application_form.application_choices.build(
      id: 456,
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
    course_option = FactoryBot.build_stubbed(:course_option)
    application_choice = application_form.application_choices.build(
      id: 123,
      course_option: course_option,
      status: :offer,
      offer: { conditions: ['DBS check', 'Pass exams'] },
      offered_at: Time.zone.now,
      offered_course_option: course_option,
      decline_by_default_at: 10.business_days.from_now,
    )
    other_course_option = FactoryBot.build_stubbed(:course_option)
    application_form.application_choices.build(
      id: 456,
      course_option: other_course_option,
      status: :awaiting_provider_decision,
    )
    CandidateMailer.new_offer_decisions_pending(application_choice)
  end

  def application_rejected_all_rejected
    provider = FactoryBot.create(:provider)
    course = FactoryBot.create(:course, provider: provider)
    application_form = FactoryBot.create(:application_form, first_name: 'Tyrell', last_name: 'Wellick')
    course_option = FactoryBot.create(:course_option, course: course)
    application_choice = FactoryBot.create(:application_choice,
                                           course_option: course_option,
                                           application_form: application_form,
                                           rejection_reason: 'Not enough experience.')

    CandidateMailer.application_rejected_all_rejected(application_choice)
  end

  def application_rejected_awaiting_decisions
    provider = FactoryBot.create(:provider)
    course = FactoryBot.create(:course, provider: provider)
    application_form = FactoryBot.create(:application_form, first_name: 'Tyrell', last_name: 'Wellick')
    course_option = FactoryBot.create(:course_option, course: course)
    FactoryBot.create(:application_choice, status: :awaiting_provider_decision, application_form: application_form)
    application_choice = FactoryBot.create(:application_choice,
                                           course_option: course_option,
                                           application_form: application_form,
                                           rejection_reason: 'Not enough experience.')

    CandidateMailer.application_rejected_awaiting_decisions(application_choice)
  end

  def reference_received
    CandidateMailer.reference_received(reference)
  end

  def application_rejected_offers_made
    provider = FactoryBot.create(:provider)
    course = FactoryBot.create(:course, provider: provider)
    application_form = FactoryBot.create(:application_form, first_name: 'Tyrell', last_name: 'Wellick')
    course_option = FactoryBot.create(:course_option, course: course)
    FactoryBot.create_list(:application_choice, 2, :with_offer, decline_by_default_days: 10, application_form: application_form)
    application_choice = FactoryBot.create(:application_choice,
                                           course_option: course_option,
                                           application_form: application_form,
                                           decline_by_default_days: 10,
                                           rejection_reason: 'Not enough experience.')

    CandidateMailer.application_rejected_offers_made(application_choice)
  end

private

  def application_form
    @application_form ||= FactoryBot.build_stubbed(:application_form, first_name: 'Gemma')
  end

  def reference
    FactoryBot.build_stubbed(:reference, application_form: application_form)
  end

  def application_form_with_chooices(choices)
    OpenStruct.new(
      candidate: OpenStruct.new(email_address: 'candidate@email.com'),
      first_name: 'Ting',
      application_choices: choices,
    )
  end
end
