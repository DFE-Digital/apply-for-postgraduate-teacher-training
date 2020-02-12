require 'rails_helper'

RSpec.feature 'Entering their work history' do
  include CandidateHelper

  scenario 'Candidate submits their work history' do
    FeatureFlag.activate('work_breaks')

    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_work_history
    then_i_should_see_a_list_of_work_lengths

    when_i_omit_choosing_from_the_list_of_work_lengths
    then_i_should_see_work_history_length_validation_errors

    when_i_choose_more_than_5_years
    then_i_should_see_the_job_form

    when_i_fill_in_the_job_form_with_incorrect_date_fields
    then_i_should_see_date_validation_errors
    and_i_should_see_the_incorrect_date_values

    when_i_fill_in_the_job_form
    and_i_choose_no_to_adding_another_job
    then_i_should_see_my_completed_job

    when_i_click_on_delete_entry
    and_i_confirm
    then_i_should_be_asked_for_an_explanation

    when_i_click_on_add_job
    and_i_fill_in_the_job_form # 5/2014 - 1/2019
    and_i_choose_yes_to_adding_another_job
    then_i_should_see_the_job_form

    when_i_fill_in_the_job_form_with_another_job_with_a_break # 3/2019 - current
    and_i_do_not_fill_in_end_date
    and_i_choose_no_to_adding_another_job
    then_i_should_see_my_second_job
    and_i_should_see_the_length_of_the_gap_in_months # 1 months
    and_i_should_be_asked_to_explain_the_break_in_my_work_history

    when_i_click_add_another_job_for_my_break
    then_i_should_see_the_start_and_end_date_filled_in

    given_i_am_on_review_work_history_page
    when_i_click_to_enter_break_explanation
    then_i_see_the_work_history_break_form

    when_i_fill_in_the_work_history_break_form
    then_i_see_my_explanation_for_breaks_in_my_work_history

    when_i_click_on_change
    and_i_change_the_job_title_to_be_blank
    then_i_should_see_validation_errors

    when_i_change_the_job_title
    then_i_should_see_my_updated_job

    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_should_see_the_form
    and_that_the_section_is_completed
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_work_history
    click_link t('page_titles.work_history')
  end

  def then_i_should_see_a_list_of_work_lengths
    expect(page).to have_content(t('application_form.work_history.more_than_5.label'))
  end

  def when_i_omit_choosing_from_the_list_of_work_lengths
    click_button 'Continue'
  end

  def then_i_should_see_work_history_length_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/work_history_form.attributes.work_history.blank')
  end

  def when_i_choose_more_than_5_years
    choose t('application_form.work_history.more_than_5.label')
    click_button 'Continue'
  end

  def then_i_should_see_the_job_form
    expect(page).to have_content(t('page_titles.add_job'))
  end

  def when_i_fill_in_the_job_form_with_incorrect_date_fields
    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '33'
    end

    within('[data-qa="end-date"]') do
      fill_in 'Year', with: '9999'
    end

    click_button t('application_form.work_history.complete_form_button')
  end

  def then_i_should_see_date_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/work_experience_form.attributes.start_date.invalid')
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/work_experience_form.attributes.end_date.invalid')
  end

  def and_i_should_see_the_incorrect_date_values
    within('[data-qa="start-date"]') do
      expect(find_field('Month').value).to eq('33')
    end

    within('[data-qa="end-date"]') do
      expect(find_field('Year').value).to eq('9999')
    end
  end

  def when_i_fill_in_the_job_form
    scope = 'application_form.work_history'
    fill_in t('role.label', scope: scope), with: 'Chief Terraforming Officer'
    fill_in t('organisation.label', scope: scope), with: 'Weyland-Yutani'

    choose 'Part-time'

    fill_in 'Give details about your working pattern', with: 'I had a working pattern'

    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '5'
      fill_in 'Year', with: '2014'
    end

    within('[data-qa="end-date"]') do
      fill_in 'Month', with: '1'
      fill_in 'Year', with: '2019'
    end

    fill_in t('details.label', scope: scope), with: 'I gained exposure to breakthrough technologies and questionable business ethics'

    choose 'No'
  end

  def and_i_choose_no_to_adding_another_job
    choose 'No, I’ve completed my work history'

    click_button t('application_form.work_history.complete_form_button')
  end

  def and_i_choose_yes_to_adding_another_job
    choose 'Yes, I want to add another job'

    click_button t('application_form.work_history.complete_form_button')
  end

  def then_i_should_see_my_completed_job
    expect(page).to have_content('Chief Terraforming Officer')
    expect(page).to have_content('I had a working pattern')
  end

  def when_i_click_on_delete_entry
    click_link t('application_form.work_history.delete_entry')
  end

  def and_i_confirm
    click_button t('application_form.work_history.sure_delete_entry')
  end

  def then_i_should_be_asked_for_an_explanation
    expect(page).to have_content('Explanation of why you’ve been out of the workplace')
  end

  def when_i_click_on_add_job
    click_link t('application_form.work_history.add_job')
  end

  def when_i_click_on_add_another_job
    all('a', text: 'Add another job')[1].click
  end

  def and_i_fill_in_the_job_form
    when_i_fill_in_the_job_form
  end

  def when_i_fill_in_the_job_form_with_another_job_with_a_break
    scope = 'application_form.work_history'
    fill_in t('role.label', scope: scope), with: 'Chief of Xenomorph Procurement and Research'
    fill_in t('organisation.label', scope: scope), with: 'Weyland-Yutani'

    choose 'Full-time'

    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '3'
      fill_in 'Year', with: '2019'
    end

    fill_in t('details.label', scope: scope), with: 'Gimme Xenomorphs.'

    choose 'No'
  end

  def and_i_do_not_fill_in_end_date; end

  def then_i_should_see_my_second_job
    expect(page).to have_content('Chief of Xenomorph Procurement and Research')
  end

  def and_i_should_see_the_length_of_the_gap_in_months
    expect(page).to have_content('You have a break in your work history (1 month)')
  end

  def and_i_should_be_asked_to_explain_the_break_in_my_work_history
    expect(page).to have_content(t('application_form.work_history.break.label'))
  end

  def when_i_click_add_another_job_for_my_break
    first(:link, t('application_form.work_history.add_another_job')).click
  end

  def then_i_should_see_the_start_and_end_date_filled_in
    expect(page).to have_selector("input[value='1']")
    expect(page).to have_selector("input[value='2019']")
    expect(page).to have_selector("input[value='3']")
    expect(page).to have_selector("input[value='2019']")
  end

  def given_i_am_on_review_work_history_page
    visit candidate_interface_work_history_show_path
  end

  def when_i_click_to_enter_break_explanation
    click_link t('application_form.work_history.break.enter_label')
  end

  def then_i_see_the_work_history_break_form
    expect(page).to have_content(t('page_titles.work_history_breaks'))
  end

  def when_i_fill_in_the_work_history_break_form
    fill_in t('application_form.work_history.break.label'), with: 'WE WERE ON A BREAK!'

    click_button t('application_form.work_history.break.button')
  end

  def then_i_see_my_explanation_for_breaks_in_my_work_history
    expect(page).to have_content('WE WERE ON A BREAK!')
  end

  def when_i_click_on_change
    first('.govuk-summary-list__actions').click_link 'Change'
  end

  def and_i_change_the_job_title_to_be_blank
    fill_in t('application_form.work_history.role.label'), with: ''
    click_button t('application_form.work_history.complete_form_button')
  end

  def then_i_should_see_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/work_experience_form.attributes.role.blank')
  end

  def when_i_change_the_job_title
    fill_in t('application_form.work_history.role.label'), with: 'Chief Executive Officer'
    click_button t('application_form.work_history.complete_form_button')
  end

  def then_i_should_see_my_updated_job
    expect(page).to have_content('Chief Executive Officer')
  end

  def when_i_mark_this_section_as_completed
    check t('application_form.work_history.review.completed_checkbox')
  end

  def and_i_click_on_continue
    click_button t('application_form.work_history.review.button')
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#work-history-badge-id', text: 'Completed')
  end
end
