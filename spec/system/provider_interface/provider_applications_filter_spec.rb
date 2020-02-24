require 'rails_helper'

RSpec.feature 'Providers should be able to filter applications' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'can filter applications by status' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_page

    then_i_expect_to_see_the_hide_filter_button
    then_i_expect_to_see_the_filter_dialogue

    when_i_hide_the_filter_dialogue
    then_i_do_not_expect_to_see_the_filter_dialogue

    when_i_show_the_filter_dialogue
    then_i_expect_to_see_the_filter_dialogue

    and_filter_for_rejected_applications

    then_only_rejected_applications_should_be_visible
  end

  def when_i_visit_the_provider_page
    visit provider_interface_path
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def and_my_organisation_has_courses_with_applications
    current_provider = create(:provider, :with_signed_agreement, code: 'ABC')

    course_option_one = course_option_for_provider(provider: current_provider, course: create(:course, name: 'Alchemy', provider: current_provider))
    course_option_two = course_option_for_provider(provider: current_provider, course: create(:course, name: 'Divination', provider: current_provider))
    course_option_three = course_option_for_provider(provider: current_provider, course: create(:course, name: 'English', provider: current_provider))

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_one, status: 'withdrawn', application_form:
           create(:application_form, first_name: 'Jim', last_name: 'James'), updated_at: 1.day.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_two, status: 'offer', application_form:
           create(:application_form, first_name: 'Adam', last_name: 'Jones'), updated_at: 2.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_two, status: 'rejected', application_form:
           create(:application_form, first_name: 'Tom', last_name: 'Jones'), updated_at: 2.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_three, status: 'declined', application_form:
           create(:application_form, first_name: 'Bill', last_name: 'Bones'), updated_at: 3.days.ago)
  end

  def then_i_expect_to_see_the_hide_filter_button
    expect(page).to have_content('Hide filter')
  end

  def then_i_expect_to_see_the_filter_dialogue
    expect(page).to have_submit_button('Apply filters')
  end

  def when_i_hide_the_filter_dialogue
    click_link('Hide filter')
  end

  def then_i_do_not_expect_to_see_the_filter_dialogue
    expect(page).not_to have_submit_button('Apply filters')
  end

  def when_i_show_the_filter_dialogue
    click_link('Show filter')
  end


  def and_filter_for_rejected_applications
    find(:css, "#status-rejected").set(true)
    click_button('Apply filters')
  end

  def then_only_rejected_applications_should_be_visible
    expect(page).to have_css('.govuk-table__body', text: 'Rejected')
    expect(page).not_to have_css('.govuk-table__body', text: 'Offer')
    expect(page).not_to have_css('.govuk-table__body', text: 'Withdrawn')
    expect(page).not_to have_css('.govuk-table__body', text: 'Declined')
  end

end
