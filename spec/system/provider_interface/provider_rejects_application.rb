require 'rails_helper'

RSpec.feature 'See applications' do
  include CourseOptionHelpers

  scenario 'Provider responds to application' do
    given_i_am_a_provider_user
    and_my_organisation_has_applications
    when_i_visit_a_application_with_status_awaiting_provider_decision
    then_i_can_see_its_status
    and_i_can_respond_to_the_application
  end

    then_i_should_be_on_the_application_view_page

    #when_i_click_on_an_application
    #then_i_should_be_on_the_application_view_page
  end

  def given_i_am_a_provider_user
    # This is stubbed out for now in the controller.
  end

  def and_my_organisation_has_applications
    course_option = course_option_for_provider_code(provider_code: 'ABC')
    other_course_option = course_option_for_provider_code(provider_code: 'ANOTHER_ORG')

    create(:application_choice, status: 'awaiting_provider_decision', course_option: course_option, application_form: create(:application_form, first_name: 'Alice', last_name: 'Wunder'))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: course_option, application_form: create(:application_form, first_name: 'Bob'))
    create(:application_choice, status: 'awaiting_provider_decision', course_option: other_course_option, application_form: create(:application_form, first_name: 'Charlie'))
  end

  def and_i_visit_the_provider_application_page
    visit provider_interface_path
  end

  def then_i_should_see_the_applications_from_my_organisation
    expect(page).to have_content 'Alice'
    expect(page).to have_content 'Bob'
  end

  def but_not_the_applications_from_other_providers
    expect(page).not_to have_content 'Charlie'
  end

  def when_i_click_on_an_application
    click_on 'Alice'
  end

  def then_i_should_be_on_the_application_view_page
    expect(page).to have_content "Alice Wunder's application"
  end
end
