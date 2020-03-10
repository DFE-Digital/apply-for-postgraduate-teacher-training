require 'rails_helper'

RSpec.feature 'Entering their suitability to work with children' do
  include CandidateHelper

  scenario 'Candidate declares any safeguarding issues' do
    given_i_am_signed_in
    and_the_suitability_to_work_with_children_feature_flag_is_off
    when_i_visit_the_site
    then_i_dont_see_declaring_any_safeguarding_issues

    when_i_visit_the_declaring_any_safeguarding_issues_form
    then_i_see_the_application_form

    given_the_suitability_to_work_with_children_feature_flag_is_on
    when_i_visit_the_site
    then_i_see_declaring_any_safeguarding_issues

    when_i_click_on_declaring_any_safeguarding_issues
    then_i_see_declaring_any_safeguarding_issues_form

    when_i_choose_yes
    and_enter_relevant_information
    and_i_click_on_continue
    then_i_see_my_relevant_information

    when_i_click_to_change_sharing_safeguarding_issues
    then_i_see_declaring_any_safeguarding_issues_form

    when_i_choose_no
    and_i_click_on_continue
    then_i_see_my_updated_answer
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def and_the_suitability_to_work_with_children_feature_flag_is_off
    FeatureFlag.deactivate('suitability_to_work_with_children')
  end

  def then_i_dont_see_declaring_any_safeguarding_issues
    expect(page).not_to have_content('Declaring any safeguarding issues')
  end

  def when_i_visit_the_declaring_any_safeguarding_issues_form
    visit candidate_interface_edit_safeguarding_path
  end

  def then_i_see_the_application_form
    expect(page).to have_content('Your application')
  end

  def given_the_suitability_to_work_with_children_feature_flag_is_on
    FeatureFlag.activate('suitability_to_work_with_children')
  end

  def then_i_see_declaring_any_safeguarding_issues
    expect(page).to have_content(t('page_titles.suitability_to_work_with_children'))
  end

  def when_i_click_on_declaring_any_safeguarding_issues
    click_link t('page_titles.suitability_to_work_with_children')
  end

  def then_i_see_declaring_any_safeguarding_issues_form
    expect(page).to have_content('Do you want to share any safeguarding issues?')
  end

  def when_i_choose_yes
    choose 'Yes'
  end

  def and_enter_relevant_information
    fill_in 'Give any relevant information', with: 'I have a criminal conviction.'
  end

  def and_i_click_on_continue
    click_button 'Continue'
  end

  def then_i_see_my_relevant_information
    expect(page).to have_content(t('page_titles.suitability_to_work_with_children'))
    expect(page).to have_content('I have a criminal conviction.')
  end

  def when_i_click_to_change_sharing_safeguarding_issues
    click_link 'Change if you want to share any safeguarding issues'
  end

  def when_i_choose_no
    choose 'No'
  end

  def then_i_see_my_updated_answer
    expect(page).to have_content(t('page_titles.suitability_to_work_with_children'))
    expect(page).to have_content('No')
  end
end
