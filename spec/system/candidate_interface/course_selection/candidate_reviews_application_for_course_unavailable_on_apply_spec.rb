require 'rails_helper'

RSpec.feature 'Candidate reviews an application to a course that becomes unavailable on apply' do
  include CandidateHelper

  scenario 'Candidate with a completed application' do
    given_i_am_signed_in
    and_the_training_with_a_disability_feature_flag_is_on
    and_the_unavailable_course_option_warnings_is_on
    and_the_covid_19_feature_flag_is_on

    when_i_have_completed_my_application
    and_the_course_i_selected_is_no_longer_open_on_apply
    and_i_review_my_application

    then_i_should_see_that_my_course_is_no_longer_on_apply
    and_i_should_see_a_link_to_ucas

    when_i_submit_the_application
    then_i_see_error_messages_for_the_things_i_was_warned_about
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_training_with_a_disability_feature_flag_is_on
    FeatureFlag.activate('training_with_a_disability')
  end

  def and_the_unavailable_course_option_warnings_is_on
    FeatureFlag.activate('unavailable_course_option_warnings')
  end

  def and_the_covid_19_feature_flag_is_on
    FeatureFlag.activate('covid_19')
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
  end

  def and_the_course_i_selected_is_no_longer_open_on_apply
    course = Course.last
    course.update(open_on_apply: false)
  end

  def and_i_review_my_application
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def then_i_should_see_that_my_course_is_no_longer_on_apply
    expect(page).to have_content(course_closed_on_apply_message)
    expect(page).to have_content("You can still apply for '#{course.name_and_code}' on UCAS.")
  end

  def and_i_should_see_a_link_to_ucas
    expect(page).to have_link('apply for this course on UCAS')
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check your answers before submitting'
  end

  def when_i_submit_the_application
    click_link 'Continue'
  end

  def then_i_see_error_messages_for_the_things_i_was_warned_about
    within('.govuk-error-summary') do
      expect(page).to have_content course_closed_on_apply_message
    end
  end

private

  def course_closed_on_apply_message
    "'#{course.name_and_code}' at #{course.provider.name} is not available on Apply for teacher training anymore"
  end

  def course
    @course ||= Course.last
  end
end
