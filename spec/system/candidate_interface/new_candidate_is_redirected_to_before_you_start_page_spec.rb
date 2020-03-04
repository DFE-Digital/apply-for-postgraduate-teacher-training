require 'rails_helper'

RSpec.feature 'A new candidate is encouraged to select a course' do
  scenario 'Candidate is redirected to the before you start page on their first sign in' do
    given_the_before_you_start_flag_is_active
    and_the_pilot_is_open

    when_i_visit_apply
    and_i_click_start_now
    and_i_fill_in_the_eligiblity_form_with_yes
    and_i_submit_my_email_address
    and_click_on_the_magic_link
    then_i_should_see_the_before_you_start_page
    and_i_should_see_an_account_created_flash_message

    when_i_click_choose_a_course
    then_i_should_see_the_course_choices_index_page

    when_i_visit_apply
    and_i_click_start_now
    and_i_fill_in_the_eligiblity_form_with_yes
    and_i_submit_my_email_address
    and_click_on_the_magic_link

    when_i_click_on_go_to_my_application
    then_i_should_see_the_application_page
  end

  def given_the_before_you_start_flag_is_active
    FeatureFlag.activate('before_you_start')
  end

  def and_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def when_i_visit_apply
    visit candidate_interface_start_path
  end

  def and_i_click_start_now
    click_on 'Start now'
  end

  def and_i_fill_in_the_eligiblity_form_with_yes
    within_fieldset('Are you a citizen of the UK or the EU?') do
      choose 'Yes'
    end

    within_fieldset('Did you gain all your qualifications at institutions based in the UK?') do
      choose 'Yes'
    end

    click_on 'Continue'
  end

  def and_i_submit_my_email_address
    @email = "#{SecureRandom.hex}@example.com"
    fill_in t('authentication.sign_up.email_address.label'), with: @email
    check t('authentication.sign_up.accept_terms_checkbox')
    click_on t('authentication.sign_up.button_continue')
  end

  def and_click_on_the_magic_link
    open_email(@email)
    current_email.find_css('a').first.click
  end

  def then_i_should_see_the_before_you_start_page
    expect(page).to have_current_path(candidate_interface_before_you_start_path)
  end

  def and_i_should_see_an_account_created_flash_message
    expect(page).to have_content(t('apply_from_find.account_created_message'))
  end

  def when_i_click_choose_a_course
    click_link 'Choose a course'
  end

  def then_i_should_see_the_course_choices_index_page
    expect(page).to have_current_path(candidate_interface_course_choices_index_path)
  end

  def when_i_visit_the_before_you_start_page
    visit candidate_interface_before_you_start_path
  end

  def when_i_click_on_go_to_my_application
    click_link 'Go to your application form'
  end

  def then_i_should_see_the_application_page
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end
end
