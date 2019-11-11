require 'rails_helper'

RSpec.feature 'Candidate submit the application' do
  include CandidateHelper

  scenario 'Candidate with personal details and contact details' do
    given_i_am_signed_in
    and_i_have_chosen_a_course
    and_i_filled_in_personal_details
    and_i_filled_in_contact_details
    and_reviewed_my_application
    and_i_confirm_my_application

    when_i_choose_to_add_further_information_but_omit_adding_details
    then_i_should_see_validation_errors

    when_i_fill_in_further_information
    and_i_can_submit_the_application

    then_i_can_see_my_application_has_been_successfully_submitted

    and_i_can_see_my_support_ref
    and_i_receive_an_email_with_my_support_ref

    when_i_click_on_track_your_application
    then_i_can_see_my_submitted_application
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_have_chosen_a_course
    provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    site = create(:site, name: 'Main site', code: '-', provider: provider)
    course = create(:course, name: 'Primary', code: '2XT2', provider: provider)
    create(:course_option, site: site, course: course, vacancy_status: 'B')

    visit candidate_interface_application_form_path

    click_link 'Course choices'
    click_link 'Add course'
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'
    select 'Gorse SCITT (1N1)'
    click_button 'Continue'
    select 'Primary (2XT2)'
    click_button 'Continue'
    choose 'Main site'
    click_button 'Continue'
  end

  def and_i_filled_in_personal_details
    visit candidate_interface_personal_details_edit_path
    candidate_fills_in_personal_details(scope: 'application_form.personal_details')

    click_button t('complete_form_button', scope: 'application_form.personal_details')
  end

  def and_i_filled_in_contact_details
    visit candidate_interface_contact_details_edit_base_path
    candidate_fills_in_contact_details

    click_button t('application_form.contact_details.address.button')
  end

  def and_reviewed_my_application
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check your answers before submitting'
  end

  def and_i_confirm_my_application
    click_link 'Continue'
  end

  def when_i_choose_to_add_further_information_but_omit_adding_details
    choose 'Yes'
  end

  def then_i_should_see_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/further_information_form.attributes.further_information_details.blank')
  end

  def when_i_fill_in_further_information
    scope = 'application_form.further_information'
    fill_in t('further_information_details.label', scope: scope), with: "How you doin', ya old pirate? So good to see ya!", match: :prefer_exact
  end

  def and_i_can_submit_the_application
    click_button 'Submit application'
  end

  def then_i_can_see_my_application_has_been_successfully_submitted
    expect(page).to have_content 'Application successfully submitted'
  end

  def and_i_can_see_my_support_ref
    support_ref = page.find('span#application-ref').text
    expect(support_ref).not_to be_empty
  end

  def and_i_receive_an_email_with_my_support_ref
    open_email(current_candidate.email_address)
    expect(current_email).to have_content 'Application submitted'
  end

  def when_i_click_on_track_your_application
    click_link t('submit_application_success.track_your_application')
  end

  def then_i_can_see_my_submitted_application
    this_day = Time.now.strftime('%-e %B %Y')
    expect(page).to have_content "You submitted your application on #{this_day}"
  end
end
