require 'rails_helper'

RSpec.feature 'Entering their contact information' do
  include CandidateHelper

  scenario 'Candidate submits their contact information' do
    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_contact_information
    and_i_incorrectly_fill_in_my_phone_number
    and_i_submit_my_phone_number
    then_i_should_see_validation_errors_for_my_phone_number
    and_a_validation_error_is_logged_for_phone_number

    when_i_fill_in_my_phone_number
    and_i_submit_my_phone_number
    and_i_select_live_in_uk
    and_i_incorrectly_fill_in_my_address
    and_i_submit_my_address
    then_i_should_see_validation_errors_for_my_address

    when_i_fill_in_my_address
    and_i_submit_my_address
    then_i_can_check_my_answers

    when_i_click_to_change_my_phone_number
    then_i_can_see_my_phone_number

    when_i_fill_in_a_different_phone_number
    and_i_submit_my_phone_number
    then_i_can_check_my_revised_phone_number

    when_i_click_to_change_my_address_type
    then_i_can_see_my_address_type

    when_i_select_outside_the_uk
    and_i_incorrectly_fill_in_my_international_address
    and_i_submit_my_address
    then_i_should_see_validation_errors_for_address_line1

    when_i_fill_in_an_international_address
    and_i_submit_my_address
    then_i_can_check_my_revised_address

    when_i_submit_my_details
    then_i_see_a_section_complete_error

    when_i_mark_the_section_as_completed
    and_i_submit_my_details
    then_i_should_see_the_form
    and_that_the_section_is_completed

    when_i_click_on_contact_information
    then_i_can_check_my_revised_answers
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_contact_information
    click_link t('page_titles.contact_information')
  end

  def and_i_incorrectly_fill_in_my_phone_number
    fill_in t('application_form.contact_details.phone_number.label'), with: '07700 CAT DOG'
  end

  def and_i_submit_my_phone_number
    click_button t('save_and_continue')
  end

  def then_i_should_see_validation_errors_for_my_phone_number
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/contact_details_form.attributes.phone_number.invalid')
  end

  def and_a_validation_error_is_logged_for_phone_number
    validation_error = ValidationError.last
    expect(validation_error).to be_present
    expect(validation_error.details).to have_key('phone_number')
    expect(validation_error.user).to eq(current_candidate)
    expect(validation_error.request_path).to eq(candidate_interface_new_phone_number_path)
    expect(validation_error.service).to eq('apply')
  end

  def when_i_fill_in_my_phone_number
    fill_in t('application_form.contact_details.phone_number.label'), with: '07700 900 982'
  end

  def and_i_select_live_in_uk
    expect(page).to have_content('Where do you live?')
    choose 'In the UK'
    click_button t('save_and_continue')
  end

  def and_i_incorrectly_fill_in_my_address
    fill_in t('application_form.contact_details.address_line3.label.uk'), with: 'London'
    fill_in t('application_form.contact_details.postcode.label.uk'), with: 'MUCH W0W'
  end

  def then_i_should_see_validation_errors_for_my_address
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/contact_details_form.attributes.address_line1.blank')
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/contact_details_form.attributes.postcode.invalid')
  end

  def when_i_fill_in_my_address
    find(:css, "[autocomplete='address-line1']").fill_in with: '42 Much Wow Street'
    fill_in t('application_form.contact_details.address_line3.label.uk'), with: 'London'
    fill_in t('application_form.contact_details.postcode.label.uk'), with: 'SW1P 3BT'
  end

  def and_i_submit_my_address
    click_button t('save_and_continue')
  end

  def then_i_can_check_my_answers
    expect(page).to have_content t('application_form.contact_details.phone_number.label')
    expect(page).to have_content '07700 900 982'
  end

  def when_i_click_to_change_my_phone_number
    find_link('Change', href: candidate_interface_edit_phone_number_path).click
  end

  def then_i_can_see_my_phone_number
    expect(page).to have_selector("input[value='07700 900 982']")
  end

  def when_i_fill_in_a_different_phone_number
    fill_in t('application_form.contact_details.phone_number.label'), with: '07700 424 242'
  end

  def then_i_can_check_my_revised_phone_number
    expect(page).to have_content t('application_form.contact_details.phone_number.label')
    expect(page).to have_content '07700 424 242'
  end

  def when_i_click_to_change_my_address_type
    find_link('Change', href: candidate_interface_edit_address_type_path).click
  end

  def then_i_can_see_my_address_type
    expect(page).to have_selector("input[value='uk']")
  end

  def when_i_select_outside_the_uk
    expect(page).to have_content('Where do you live?')
    choose 'Outside the UK'
    select('India', from: t('application_form.contact_details.country.label'))
    click_button t('save_and_continue')
  end

  def and_i_incorrectly_fill_in_my_international_address
    fill_in 'candidate_interface_contact_details_form[address_line1]', with: ''
    fill_in 'candidate_interface_contact_details_form[address_line2]', with: 'New Delhi'
    fill_in 'candidate_interface_contact_details_form[address_line4]', with: '110006'
  end

  def then_i_should_see_validation_errors_for_address_line1
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/contact_details_form.attributes.address_line1.blank')
  end

  def when_i_fill_in_an_international_address
    fill_in 'candidate_interface_contact_details_form[address_line1]', with: '123 Chandni Chowk'
    fill_in 'candidate_interface_contact_details_form[address_line3]', with: 'New Delhi'
    fill_in 'candidate_interface_contact_details_form[address_line4]', with: '110006'
  end

  def then_i_can_check_my_revised_address
    expect(page).to have_content '123 Chandni Chowk'
    expect(page).to have_content 'New Delhi'
    expect(page).to have_content '110006'
    expect(page).to have_content 'India'
  end

  def when_i_mark_the_section_as_completed
    choose t('application_form.completed_radio')
  end

  def and_i_submit_my_details
    click_button t('continue')
  end

  def when_i_submit_my_details
    and_i_submit_my_details
  end

  def then_i_see_a_section_complete_error
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/section_complete_form.attributes.completed.blank')
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#contact-information-badge-id', text: 'Completed')
  end

  def then_i_can_check_my_revised_answers
    then_i_can_check_my_revised_phone_number
    then_i_can_check_my_revised_address
  end
end
