require 'rails_helper'

RSpec.feature 'Reasons for rejection dashboard' do
  include DfESignInHelpers

  around do |example|
    @today = Time.zone.local(2020, 12, 24, 12)
    Timecop.freeze(@today) do
      example.run
    end
  end

  scenario 'View reasons for rejection', with_audited: true do
    given_i_am_a_support_user
    and_there_are_candidates_and_application_forms_in_the_system

    when_i_visit_the_performance_page_in_support
    and_i_click_on_the_reasons_for_rejection_metrics_link

    then_i_should_see_reasons_for_rejection_metrics
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_and_application_forms_in_the_system
    allow(EndOfCycleTimetable).to receive(:apply_reopens).and_return(60.days.ago)
    application_choice1 = create(:application_choice, :awaiting_provider_decision)
    application_choice2 = create(:application_choice, :awaiting_provider_decision)
    application_choice3 = create(:application_choice, :awaiting_provider_decision)
    application_choice4 = create(:application_choice, :awaiting_provider_decision)
    application_choice5 = create(:application_choice, :awaiting_provider_decision)
    application_choice6 = create(:application_choice, :awaiting_provider_decision)

    Timecop.freeze(@today - 40.days) do
      reject_application_for_candidate_behaviour_qualifications_and_safeguarding(application_choice1)
      reject_application_for_candidate_behaviour_and_qualifications(application_choice2)
      reject_application_for_candidate_behaviour(application_choice3)
    end

    Timecop.freeze(@today) do
      reject_application_for_candidate_behaviour_qualifications_and_safeguarding(application_choice4)
      reject_application_for_candidate_behaviour(application_choice5)
      reject_application_without_structured_reasons(application_choice6)
    end
  end

  def when_i_visit_the_performance_page_in_support
    visit support_interface_performance_path
  end

  def and_i_click_on_the_reasons_for_rejection_metrics_link
    click_on 'Reasons for rejection'
  end

  def then_i_should_see_reasons_for_rejection_metrics
    then_i_should_see_reasons_for_rejection_course_full
    and_i_should_see_reasons_for_rejection_candidate_behaviour
    and_i_should_see_reasons_for_rejection_honesty_and_professionalism
    and_i_should_see_reasons_for_rejection_interested_in_future_applications
    and_i_should_see_reasons_for_rejection_offered_on_another_course
    and_i_should_see_reasons_for_rejection_other_advice_or_feedback
    and_i_should_see_reasons_for_rejection_performance_at_interview
    and_i_should_see_reasons_for_rejection_qualifications
    and_i_should_see_reasons_for_rejection_quality_of_application
    and_i_should_see_reasons_for_rejection_safeguarding_concerns
  end

private

  def reject_application_for_candidate_behaviour_qualifications_and_safeguarding(application_choice)
    application_choice.update!(
      status: :rejected,
      structured_rejection_reasons: {
        course_full_y_n: 'No',
        candidate_behaviour_y_n: 'Yes',
        honesty_and_professionalism_y_n: 'No',
        performance_at_interview_y_n: 'No',
        qualifications_y_n: 'Yes',
        quality_of_application_y_n: 'No',
        safeguarding_y_n: 'Yes',
        offered_on_another_course_y_n: 'No',
        interested_in_future_applications_y_n: 'No',
        other_advice_or_feedback_y_n: 'No',
      },
      rejected_at: Time.zone.now,
    )
  end

  def reject_application_for_candidate_behaviour_and_qualifications(application_choice)
    application_choice.update!(
      status: :rejected,
      structured_rejection_reasons: {
        course_full_y_n: 'No',
        candidate_behaviour_y_n: 'Yes',
        honesty_and_professionalism_y_n: 'No',
        performance_at_interview_y_n: 'No',
        qualifications_y_n: 'Yes',
        quality_of_application_y_n: 'No',
        safeguarding_y_n: 'No',
        offered_on_another_course_y_n: 'No',
        interested_in_future_applications_y_n: 'No',
        other_advice_or_feedback_y_n: 'No',
      },
      rejected_at: Time.zone.now,
    )
  end

  def reject_application_for_candidate_behaviour(application_choice)
    application_choice.update!(
      status: :rejected,
      structured_rejection_reasons: {
        course_full_y_n: 'No',
        candidate_behaviour_y_n: 'Yes',
        honesty_and_professionalism_y_n: 'No',
        performance_at_interview_y_n: 'No',
        qualifications_y_n: 'No',
        quality_of_application_y_n: 'No',
        safeguarding_y_n: 'No',
        offered_on_another_course_y_n: 'No',
        interested_in_future_applications_y_n: 'No',
        other_advice_or_feedback_y_n: 'No',
      },
      rejected_at: Time.zone.now,
    )
  end

  def reject_application_without_structured_reasons(application_choice)
    application_choice.update!(
      status: :rejected,
      rejected_at: Time.zone.now,
    )
  end

  def then_i_should_see_reasons_for_rejection_course_full
    within '#course_full' do
      expect(page).to have_content('0%')
      expect(page).to have_content('0 of 5 application choices')
      expect(page).to have_content('0 total')
      expect(page).to have_content('0 this month')
    end
  end

  def and_i_should_see_reasons_for_rejection_candidate_behaviour
    within '#candidate_behaviour' do
      expect(page).to have_content('100%')
      expect(page).to have_content('5 of 5 application choices')
      expect(page).to have_content('5 total')
      expect(page).to have_content('2 this month')
    end
  end

  def and_i_should_see_reasons_for_rejection_honesty_and_professionalism
    within '#honesty_and_professionalism' do
      expect(page).to have_content('0%')
      expect(page).to have_content('0 of 5 application choices')
      expect(page).to have_content('0 total')
      expect(page).to have_content('0 this month')
    end
  end

  def and_i_should_see_reasons_for_rejection_offered_on_another_course
    within '#offered_on_another_course' do
      expect(page).to have_content('0%')
      expect(page).to have_content('0 of 5 application choices')
      expect(page).to have_content('0 total')
      expect(page).to have_content('0 this month')
    end
  end

  def and_i_should_see_reasons_for_rejection_performance_at_interview
    within '#performance_at_interview' do
      expect(page).to have_content('0%')
      expect(page).to have_content('0 of 5 application choices')
      expect(page).to have_content('0 total')
      expect(page).to have_content('0 this month')
    end
  end

  def and_i_should_see_reasons_for_rejection_qualifications
    within '#qualifications' do
      expect(page).to have_content('60%')
      expect(page).to have_content('3 of 5 application choices')
      expect(page).to have_content('3 total')
      expect(page).to have_content('1 this month')
    end
  end

  def and_i_should_see_reasons_for_rejection_quality_of_application
    within '#quality_of_application' do
      expect(page).to have_content('0%')
      expect(page).to have_content('0 of 5 application choices')
      expect(page).to have_content('0 total')
      expect(page).to have_content('0 this month')
    end
  end

  def and_i_should_see_reasons_for_rejection_safeguarding_concerns
    within '#safeguarding_concerns' do
      expect(page).to have_content('40%')
      expect(page).to have_content('2 of 5 application choices')
      expect(page).to have_content('2 total')
      expect(page).to have_content('1 this month')
    end
  end

  def and_i_should_see_reasons_for_rejection_interested_in_future_applications
    within '#interested_in_future_applications' do
      expect(page).to have_content('0%')
      expect(page).to have_content('0 of 5 application choices')
      expect(page).to have_content('0 total')
      expect(page).to have_content('0 this month')
    end
  end

  def and_i_should_see_reasons_for_rejection_other_advice_or_feedback
    within '#other_advice_or_feedback' do
      expect(page).to have_content('0%')
      expect(page).to have_content('0 of 5 application choices')
      expect(page).to have_content('0 total')
      expect(page).to have_content('0 this month')
    end
  end
end
