require 'rails_helper'

RSpec.describe 'A Provider viewing an individual application' do
  include CourseOptionHelpers
  include DfeSignInHelpers

  scenario 'the application data is visible' do
    given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    and_my_organisation_has_received_an_application

    when_i_visit_that_application_in_the_provider_interface

    then_i_should_see_the_candidates_degrees
    and_i_should_see_the_candidates_gcses
    and_i_should_see_the_candidates_other_qualifications

    and_i_should_see_the_candidates_personal_statement
    and_i_should_see_the_candidates_language_skills
  end

  def given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end

  def and_my_organisation_has_received_an_application
    course_option = course_option_for_provider_code(provider_code: 'ABC')
    application_form = create(:application_form,
                              becoming_a_teacher: 'This is my personal statement',
                              subject_knowledge: 'This is my subject knowledge',
                              interview_preferences: 'Any date is fine',
                              further_information: 'Nothing further to add',
                              english_main_language: true,
                              english_language_details: 'I also speak Spanish and German')

    create_list(:application_qualification, 1, application_form: application_form, level: :degree)
    create_list(:application_qualification, 2, application_form: application_form, level: :gcse)
    create_list(:application_qualification, 3, application_form: application_form, level: :other)

    @application_choice = create(:application_choice,
                                 status: 'awaiting_provider_decision',
                                 course_option: course_option,
                                 application_form: application_form)
  end

  def when_i_visit_that_application_in_the_provider_interface
    visit provider_interface_application_choice_path(@application_choice)
  end

  def then_i_should_see_the_candidates_degrees
    expect(page).to have_selector('[data-qa="qualifications-table-degree"] tbody tr', count: 1)
  end

  def and_i_should_see_the_candidates_gcses
    expect(page).to have_selector('[data-qa="qualifications-table-gcse-or-equivalent"] tbody tr', count: 2)
  end

  def and_i_should_see_the_candidates_other_qualifications
    expect(page).to have_selector('[data-qa="qualifications-table-other-qualification"] tbody tr', count: 3)
  end

  def and_i_should_see_the_candidates_personal_statement
    expect(page).to have_content 'This is my personal statement'
    expect(page).to have_content 'This is my subject knowledge'
    expect(page).to have_content 'Any date is fine'
    expect(page).to have_content 'Nothing further to add'
  end

  def and_i_should_see_the_candidates_language_skills
    within '[data-qa="language-skills"]' do
      expect(page).to have_content 'Yes'
      expect(page).to have_content 'I also speak Spanish and German'
    end
  end
end
