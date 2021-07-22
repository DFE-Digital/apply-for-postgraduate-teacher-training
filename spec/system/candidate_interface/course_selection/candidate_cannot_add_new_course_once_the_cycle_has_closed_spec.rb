require 'rails_helper'

RSpec.describe 'Candidate vists their application form after the cycle has ended' do
  include CandidateHelper
  include CycleTimetableHelper

  around do |example|
    Timecop.freeze(mid_cycle) do
      example.run
    end
  end

  scenario 'The candidate cannot add new courses to their application form' do
    given_i_am_signed_in
    when_i_visit_the_site
    then_there_is_a_link_to_the_course_choices_section

    given_it_is_after_the_apply1_deadline
    and_i_logout
    and_i_am_signed_in

    when_i_visit_the_site
    then_i_am_redirected_to_the_carry_over_interstitial

    when_i_click_continue
    then_i_see_that_i_can_add_new_course_choices_in_october
    and_there_is_not_a_link_to_the_course_choices_section

    when_i_click_review_your_application
    then_i_see_that_i_can_add_new_course_choices_in_october

    when_i_try_to_visit_the_pick_provider_page
    then_i_am_redirected_back_to_the_application_form

    given_the_new_cycle_is_open
    and_i_logout
    and_i_am_signed_in

    given_my_application_forms_phase_is_apply_2
    and_it_is_before_the_apply_2_deadline

    when_i_visit_the_site
    # Need to find out if this assertion is still correct given the changes
    # No link appears because CycleHelper.can_add_course_choice? returns false
    then_there_is_a_link_to_the_apply_again_course_choices_section
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def then_there_is_a_link_to_the_course_choices_section
    expect(page).to have_link('Choose your courses')
  end

  def then_there_is_a_link_to_the_apply_again_course_choices_section
    expect(page).to have_link('Choose your course')
  end

  def given_it_is_after_the_apply1_deadline
    Timecop.travel(after_apply_1_deadline)
  end

  def then_i_see_that_i_can_add_new_course_choices_in_october
    expect(page).to have_content "You’ll be able to find courses in #{(CycleTimetable.find_reopens.to_date - Time.zone.today).to_i} days (#{CycleTimetable.find_reopens.to_s(:govuk_date)}). You can keep making changes to the rest of your application until then."
  end

  def and_there_is_not_a_link_to_the_course_choices_section
    expect(page).not_to have_link('Choose your courses')
  end

  def when_i_click_review_your_application
    click_link 'Review your application'
  end

  def when_i_try_to_visit_the_pick_provider_page
    visit candidate_interface_course_choices_provider_path
  end

  def then_i_am_redirected_back_to_the_application_form
    expect(page).to have_current_path candidate_interface_application_form_path
  end

  def given_the_new_cycle_is_open
    Timecop.travel(after_apply_reopens)
  end

  def and_i_logout
    logout
  end

  def and_i_am_signed_in
    given_i_am_signed_in
  end

  def given_my_application_forms_phase_is_apply_2
    create(
      :application_form,
      subsequent_application_form: current_candidate.current_application,
    )
    current_candidate.current_application.apply_2!
  end

  def and_it_is_before_the_apply_2_deadline
    Timecop.travel(CycleTimetable.apply_2_deadline(2021) - 1.day)
  end

  def then_i_am_redirected_to_the_carry_over_interstitial
    expect(page).to have_current_path candidate_interface_start_carry_over_path
  end

  def when_i_click_continue
    click_button 'Continue'
  end
end
