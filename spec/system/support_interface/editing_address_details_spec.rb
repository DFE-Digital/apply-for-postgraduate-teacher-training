require 'rails_helper'

RSpec.feature 'Editing address' do
  include DfESignInHelpers

  scenario 'Support user edits address', with_audited: true do
    given_i_am_a_support_user
    and_an_application_exists

    when_i_visit_the_application_page
    and_i_click_the_change_link_next_to_address
    then_i_should_see_the_address_type_page

    when_i_select_uk
    then_i_should_see_the_uk_address_details_form

    when_i_submit_the_update_form
    then_i_should_see_blank_audit_comment_error_message

    when_i_complete_the_details_form
    and_i_submit_the_update_form
    then_i_should_see_a_flash_message
    and_i_should_see_the_new_details
    and_i_should_see_my_details_comment_in_the_audit_log

    when_i_visit_the_application_page
    and_i_click_the_change_link_next_to_address
    and_i_select_outside_the_uk
    then_i_should_see_the_international_address_details_form

    when_i_submit_the_update_form
    then_i_should_see_blank_error_messages
    when_i_fill_in_an_international_address

    and_i_submit_the_update_form
    then_i_should_see_a_flash_message
    and_i_should_see_the_new_international_address_details
    and_i_should_see_my_international_address_details_comment_in_the_audit_log
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

  def and_i_click_the_change_link_next_to_address
    click_link('Change address')
  end

  def then_i_should_see_the_address_type_page
    expect(page).to have_content('Where does the candidate live?')
  end

  def when_i_select_uk
    choose 'In the UK'
    click_button t('save_and_continue')
  end

  def then_i_should_see_the_uk_address_details_form
    expect(page).to have_content('What is the candidate’s address?')
    expect(page).to have_content('Town or city')
  end

  def when_i_submit_the_update_form
    click_button t('save_and_continue')
  end
  alias_method :and_i_submit_the_update_form, :when_i_submit_the_update_form

  def then_i_should_see_blank_audit_comment_error_message
    expect(page).to have_content t('activemodel.errors.models.support_interface/application_forms/edit_address_details_form.attributes.audit_comment.blank')
  end

  def when_i_complete_the_details_form
    find(:css, "[autocomplete='address-line1']").fill_in with: '42 Much Wow Street'
    fill_in t('application_form.contact_details.address_line3.label.uk'), with: 'London'
    fill_in t('application_form.contact_details.postcode.label.uk'), with: 'SW1P 3BT'
    fill_in 'support_interface_application_forms_edit_address_details_form[audit_comment]', with: 'Updated as part of Zen Desk ticket #12345'
  end

  def then_i_should_see_a_flash_message
    expect(page).to have_content 'Address details updated'
  end

  def and_i_should_see_the_new_details
    expect(page).to have_content '42 Much Wow Street'
    expect(page).to have_content 'London'
    expect(page).to have_content 'SW1P 3BT'
  end

  def and_i_should_see_my_details_comment_in_the_audit_log
    click_on 'History'
    expect(page).to have_content 'Updated as part of Zen Desk ticket #12345'
  end

  def and_i_select_outside_the_uk
    choose 'Outside the UK'
    select('India', from: t('application_form.contact_details.country.label'))
    click_button t('save_and_continue')
  end

  def then_i_should_see_the_international_address_details_form
    expect(page).to have_content('What is the candidate’s address?')
    expect(page).to have_content('Address line 1')
  end

  def then_i_should_see_blank_error_messages
    expect(page).to have_content t('activemodel.errors.models.support_interface/application_forms/edit_address_details_form.attributes.audit_comment.blank')
  end

  def when_i_fill_in_an_international_address
    fill_in 'support_interface_application_forms_edit_address_details_form[address_line1]', with: '123 Chandni Chowk'
    fill_in 'support_interface_application_forms_edit_address_details_form[address_line3]', with: 'New Delhi'
    fill_in 'support_interface_application_forms_edit_address_details_form[address_line4]', with: '110006'
    fill_in 'support_interface_application_forms_edit_address_details_form[audit_comment]', with: 'Updated as part of Zen Desk ticket #56789'
  end

  def and_i_should_see_the_new_international_address_details
    expect(page).to have_content '123 Chandni Chowk'
    expect(page).to have_content 'New Delhi'
    expect(page).to have_content '110006'
    expect(page).to have_content 'India'
  end

  def and_i_should_see_my_international_address_details_comment_in_the_audit_log
    click_on 'History'
    expect(page).to have_content 'Updated as part of Zen Desk ticket #56789'
  end
end
