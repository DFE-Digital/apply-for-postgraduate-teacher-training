require 'rails_helper'

RSpec.feature 'Entering their personal details' do
  include CandidateHelper

  scenario 'Candidate submits their personal details' do
    given_i_am_signed_in
    and_the_international_candidates_flag_is_active
    and_i_visit_the_site

    # Entering details
    when_i_click_on_personal_details
    and_i_fill_in_some_details_but_omit_some_required_details
    and_i_submit_the_form
    then_i_should_see_validation_errors
    and_i_should_see_the_completed_fields

    when_i_fill_in_the_rest_of_my_details
    and_i_submit_the_form
    then_i_see_the_nationalites_page

    when_i_check_that_i_am_british
    and_i_submit_the_form
    then_i_see_the_languages_page

    when_i_choose_that_english_is_my_primary_language
    and_i_submit_the_form
    then_i_see_the_personal_details_review_page
    and_i_can_check_my_answers

    # Editing
    when_i_click_change_on_my_nationality
    and_i_uncheck_that_i_am_british
    and_i_check_that_i_am_irish
    and_i_submit_the_form

    then_i_see_the_personal_details_review_page
    and_i_see_my_updated_nationality

    when_i_click_change_on_my_nationality
    and_i_uncheck_that_i_am_irish
    and_i_check_other
    and_select_i_am_english
    and_i_submit_the_form
    then_i_see_the_personal_details_review_page
    and_i_see_i_am_english

    when_i_click_change_on_my_nationality
    and_i_select_i_am_german_dutch_and_belgian
    and_i_submit_the_form
    then_i_see_the_right_to_work_or_study_page

    when_i_choose_i_do_not_know
    and_i_submit_the_form
    then_i_see_the_personal_details_review_page
    and_i_can_see_my_updated_details

    when_i_click_change_on_my_right_to_work
    and_i_choose_yes
    and_i_submit_the_form
    then_i_am_told_i_need_to_provide_details

    when_i_fill_in_my_right_to_work_details
    and_i_submit_the_form
    then_i_see_the_personal_details_review_page
    and_i_can_see_my_updated_right_to_work

    when_i_vist_the_homepage
    and_i_click_on_personal_details
    then_i_see_the_personal_details_review_page

    when_i_mark_the_section_as_completed
    and_i_submit_my_details
    then_i_should_see_my_application_form
    and_that_the_section_is_completed
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_international_candidates_flag_is_active
    FeatureFlag.activate('international_personal_details')
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_personal_details
    click_link t('page_titles.personal_details')
  end

  def and_i_fill_in_some_details_but_omit_some_required_details
    @scope = 'application_form.personal_details'
    fill_in t('first_name.label', scope: @scope), with: 'Lando'
    fill_in t('last_name.label', scope: @scope), with: 'Calrissian'
    fill_in 'Month', with: '11'
  end

  def then_i_should_see_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/personal_details_form.attributes.date_of_birth.invalid')
  end

  def and_i_should_see_the_completed_fields
    expect(find_field(t('first_name.label', scope: @scope)).value).to eq('Lando')
    expect(find_field(t('last_name.label', scope: @scope)).value).to eq('Calrissian')
    expect(find_field('Month').value).to eq('11')
  end

  def when_i_fill_in_the_rest_of_my_details
    fill_in 'Day', with: '6'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '1937'
  end

  def and_i_submit_the_form
    click_button t('application_form.personal_details.complete_form_button')
  end

  def then_i_see_the_nationalites_page
    expect(page).to have_current_path candidate_interface_nationalities_path
  end

  def when_i_check_that_i_am_british
    check 'British'
  end

  def then_i_see_the_languages_page
    expect(page).to have_current_path candidate_interface_languages_path
  end

  def when_i_choose_that_english_is_my_primary_language
    choose 'Yes'
    fill_in(
      t('english_main_language.yes_label', scope: @scope),
      with: "I'm great at Galactic Basic so English is a piece of cake",
      match: :prefer_exact,
    )
  end

  def then_i_see_the_personal_details_review_page
    expect(page).to have_current_path candidate_interface_personal_details_show_path
  end

  def and_i_can_check_my_answers
    expect(page).to have_content 'Name'
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content 'British'
  end

  def when_i_click_change_on_my_nationality
    all('.govuk-summary-list__actions')[2].click_link 'Change'
  end

  def and_i_uncheck_that_i_am_british
    uncheck 'British'
  end

  def and_i_check_that_i_am_irish
    check 'Irish'
  end

  def and_i_see_my_updated_nationality
    expect(page).to have_content 'Irish'
    expect(page).not_to have_content 'British'
  end

  def and_i_uncheck_that_i_am_irish
    uncheck 'Irish'
  end

  def and_i_check_other
    check 'Other'
  end

  def and_select_i_am_english
    within all('.govuk-form-group')[1] do
      select 'English'
    end
  end

  def and_i_see_i_am_english
    expect(page).to have_content 'English'
  end

  def and_i_select_i_am_german_dutch_and_belgian
    within all('.govuk-form-group')[1] do
      select 'Belgian'
    end
    within all('.govuk-form-group')[2] do
      select 'Dutch'
    end
    within all('.govuk-form-group')[3] do
      select 'German'
    end
  end

  def and_i_see_i_am_german
    expect(page).to have_content 'German'
  end

  def then_i_see_the_right_to_work_or_study_page
    within 'main h2' do
      expect(page).to have_content 'Do you have the right to work or study in the UK?'
    end
  end

  def and_i_choose_yes
    choose 'Yes'
  end

  def when_i_choose_i_do_not_know
    choose 'I do not know'
  end

  def then_i_am_told_i_need_to_provide_details
    expect(page).to have_content 'Please provide details of your right to work or study in the UK.'
  end

  def when_i_fill_in_my_right_to_work_details
    fill_in :details, with: "Borders? I don't believe in no stinking borders."
  end

  def and_i_can_see_my_updated_details
    expect(page).to have_content 'Belgian, Dutch, and German'
    expect(page).to have_content 'I do not know'
  end

  def when_i_click_change_on_my_right_to_work
    all('.govuk-summary-list__actions')[3].click_link 'Change'
  end

  def and_i_can_see_my_updated_right_to_work
    expect(page).to have_content "Borders? I don't believe in no stinking borders."
    expect(page).to have_content 'I have the right to work or study in the UK'
  end

  def when_i_vist_the_homepage
    and_i_visit_the_site
  end

  def and_i_click_on_personal_details
    when_i_click_on_personal_details
  end

  def when_i_mark_the_section_as_completed
    check t('application_form.completed_checkbox')
  end

  def and_i_submit_my_details
    click_button 'Continue'
  end

  def then_i_should_see_my_application_form
    expect(page).to have_content(t('page_titles.personal_details'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#personal-details-badge-id', text: 'Completed')
  end
end
