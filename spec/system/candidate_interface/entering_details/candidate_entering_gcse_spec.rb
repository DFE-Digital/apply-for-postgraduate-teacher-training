require 'rails_helper'

RSpec.feature 'Candidate entering GCSE details' do
  include CandidateHelper

  scenario 'Candidate submits their maths GCSE details and then update them' do
    given_i_am_signed_in

    when_i_visit_the_candidate_application_page
    and_i_click_on_the_maths_gcse_link
    then_i_see_the_add_gcse_maths_page

    when_i_do_not_select_any_gcse_option
    and_i_click_save_and_continue
    then_i_see_the_qualification_type_error

    when_i_select_gcse_option
    and_i_click_save_and_continue
    then_i_see_add_grade_page

    when_i_fill_in_the_grade
    and_i_click_save_and_continue
    then_i_see_add_year_page

    when_i_fill_in_the_year
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_correct_details

    when_i_click_continue
    then_i_see_a_section_complete_error

    when_i_click_to_change_qualification_type
    then_i_see_the_gcse_option_selected

    when_i_select_a_different_qualification_type
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_updated_qualification_type

    when_i_click_to_change_grade
    then_i_see_the_gcse_grade_entered

    when_i_enter_a_different_qualification_grade
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_updated_grade

    when_i_click_to_change_year
    then_i_see_the_gcse_year_entered

    when_i_enter_a_different_qualification_year
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_updated_year

    when_i_mark_the_section_as_completed
    and_click_continue
    then_i_see_the_maths_gcse_is_completed

    when_i_click_on_the_english_gcse_link
    then_i_see_the_add_gcse_english_page

    when_i_select_gcse_option
    and_i_click_save_and_continue
    then_i_see_add_english_grade_page

    when_i_choose_to_return_later
    then_i_am_returned_to_the_application_form
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def given_i_am_not_signed_in; end

  def and_i_click_on_the_maths_gcse_link
    click_on 'Maths GCSE or equivalent'
  end

  def when_i_select_gcse_option
    choose('GCSE')
  end

  def when_i_select_gce_option
    choose('O Level')
  end

  def and_i_click_save_and_continue
    click_button t('save_and_continue')
  end

  def when_i_do_not_select_any_gcse_option; end

  def when_i_visit_the_candidate_application_page
    visit '/candidate/application'
  end

  def then_the_maths_gcse_should_be_incomplete
    expect(page).to have_content 'Maths GCSE or equivalent Incomplete'
  end

  def then_i_see_the_add_gcse_maths_page
    expect(page).to have_content 'Add maths GCSE grade 4 (C) or above, or equivalent'
  end

  def then_i_see_the_review_page_with_correct_details
    expect(page).to have_content 'Maths GCSE or equivalent'

    expect(page).to have_content 'GCSE'
    expect(page).to have_content 'A'
    expect(page).to have_content '1990'
  end

  def then_i_see_the_review_page_with_updated_qualification_type
    expect(page).to have_content 'Scottish National 5'
  end

  def then_i_see_the_review_page_with_updated_grade
    expect(page).to have_content 'BB'
  end

  def then_i_see_the_review_page_with_updated_year
    expect(page).to have_content '2000'
  end

  def then_i_see_add_grade_page
    expect(page).to have_content t('gcse_edit_grade.page_title', subject: 'maths', qualification_type: 'GCSE')
  end

  def then_i_see_add_year_page
    expect(page).to have_content t('gcse_edit_year.page_title', subject: 'maths', qualification_type: 'GCSE')
  end

  def when_i_fill_in_the_grade
    fill_in 'Please specify your grade', with: 'A'
  end

  def when_i_fill_in_the_year
    fill_in 'Enter year', with: '1990'
  end

  def then_i_see_the_qualification_type_error
    expect(page).to have_content 'Enter the type of qualification'
  end

  def then_i_see_the_gcse_option_selected
    expect(find_field('GCSE')).to be_checked
  end

  def then_i_see_the_gcse_grade_entered
    expect(page).to have_selector("input[value='A']")
  end

  def then_i_see_the_gcse_year_entered
    expect(page).to have_selector("input[value='1990']")
  end

  def then_i_see_a_section_complete_error
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/section_complete_form.attributes.completed.blank')
  end

  def when_i_select_a_different_qualification_type
    choose('Scottish National 5')
  end

  def when_i_click_to_change_qualification_type
    find_link('Change', href: candidate_interface_gcse_details_edit_type_path(subject: 'maths')).click
  end

  def when_i_click_to_change_year
    click_change_link('year')
  end

  def when_i_click_to_change_grade
    click_change_link('grade')
  end

  def when_i_enter_a_different_qualification_grade
    fill_in 'Please specify your grade', with: 'BB'
  end

  def when_i_enter_a_different_qualification_year
    fill_in 'Enter year', with: '2000'
  end

  def when_i_mark_the_section_as_completed
    choose t('application_form.completed_radio')
  end

  def then_i_see_the_maths_gcse_is_completed
    expect(page).to have_css('#maths-gcse-or-equivalent-badge-id', text: 'Completed')
  end

  def and_click_continue
    click_button t('continue')
  end

  def when_i_click_continue
    and_click_continue
  end

  def when_i_click_on_the_english_gcse_link
    click_on 'English GCSE or equivalent'
  end

  def then_i_see_add_english_grade_page
    expect(page).to have_content t('multiple_gcse_edit_grade.page_title')
  end

  def then_i_see_the_add_gcse_english_page
    expect(page).to have_content 'Add English GCSE grade 4 (C) or above, or equivalent'
  end

  def when_i_choose_to_return_later
    visit candidate_interface_gcse_review_path(subject: 'english')
    and_i_mark_the_section_as_incomplete
    and_click_continue
  end

  def and_i_mark_the_section_as_incomplete
    choose t('application_form.incomplete_radio')
  end

  def then_i_am_returned_to_the_application_form
    expect(page).to have_current_path candidate_interface_application_form_path
  end
end
