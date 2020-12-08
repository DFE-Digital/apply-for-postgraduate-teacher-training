require 'rails_helper'

RSpec.feature 'Editing application details' do
  include DfESignInHelpers

  scenario 'Support user edits applicant details', with_audited: true do
    given_i_am_a_support_user
    and_an_application_exists

    when_i_visit_the_application_page
    and_i_click_the_change_link_next_to_full_name
    and_i_supply_a_new_first_name
    and_i_supply_a_new_last_name
    and_i_supply_a_new_date_of_birth
    and_i_supply_a_new_phone_number
    and_i_add_a_note_for_the_audit_log

    then_i_should_see_a_flash_message
    and_i_should_see_the_new_name_in_full
    and_i_should_see_the_new_date_of_birth
    and_i_should_see_the_new_phone_number
    and_i_should_see_my_comment_in_the_audit_log
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_application_exists
    @form = create(:completed_application_form)
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@form)
  end

  def and_i_click_the_change_link_next_to_full_name
    all('.govuk-summary-list__actions')[0].click_link 'Change'
  end

  def and_i_supply_a_new_phone_number
    fill_in 'support_interface_application_forms_edit_applicant_details_form[phone_number]', with: '0891 50 50 50'
  end

  def and_i_supply_a_new_first_name
    fill_in 'support_interface_application_forms_edit_applicant_details_form[first_name]', with: 'Steven'
  end

  def and_i_supply_a_new_last_name
    fill_in 'support_interface_application_forms_edit_applicant_details_form[last_name]', with: 'Seagal'
  end

  def and_i_supply_a_new_date_of_birth
    fill_in 'Day', with: '5'
    fill_in 'Month', with: '5'
    fill_in 'Year', with: '1950'
  end

  def and_i_add_a_note_for_the_audit_log
    fill_in 'support_interface_application_forms_edit_applicant_details_form[audit_comment]', with: 'https://becomingateacher.zendesk.com/12345'

    click_button 'Update'
  end

  def then_i_should_see_a_flash_message
    expect(page).to have_content 'Applicant details updated'
  end

  def and_i_should_see_the_new_phone_number
    expect(page).to have_content '0891 50 50 50'
  end

  def and_i_should_see_the_new_name_in_full
    expect(page).to have_content 'Steven Seagal'
  end

  def and_i_should_see_the_new_date_of_birth
    expect(page).to have_content('5 May 1950')
  end

  def and_i_should_see_my_comment_in_the_audit_log
    click_on 'History'
    expect(page).to have_content 'https://becomingateacher.zendesk.com/12345'
  end
end
