require 'rails_helper'

RSpec.feature 'Entering reasons for their work history breaks' do
  include CandidateHelper

  around do |example|
    Timecop.freeze(Time.zone.local(2020, 2, 1)) do
      example.run
    end
  end

  scenario 'Candidate enters a reason for a work break' do
    FeatureFlag.activate(:restructured_work_history)

    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_work_history
    then_i_should_see_the_start_page
    then_i_choose_that_i_have_work_history_to_add
    and_i_click_add_a_first_job
    then_i_should_see_the_add_a_job_page
    and_i_add_a_job_between_february_2015_to_august_2019

    then_i_click_on_add_another_job
    and_i_add_another_job_between_november_2019_and_december_2019
    then_i_see_a_two_months_break_between_my_first_job_and_my_second_job
    and_i_see_a_one_month_break_between_my_second_job_and_now
    and_i_cannot_mark_this_section_as_complete

    given_i_am_on_review_work_history_page
    when_i_click_to_explain_my_break_between_august_2019_and_november_2019
    then_i_see_the_start_and_end_date_filled_in_for_my_break_between_august_2019_and_november_2019

    when_i_enter_a_reason_for_my_break_between_august_2019_and_november_2019
    then_i_see_my_reason_for_my_break_between_august_2019_and_november_2019_on_the_review_page

    when_i_click_to_change_my_reason_for_my_break_between_august_2019_and_november_2019
    and_i_change_my_reason_for_my_break_between_august_2019_and_november_2019
    then_i_see_my_updated_reason_for_my_break_between_august_2019_and_november_2019_on_the_review_page

    when_i_click_to_delete_my_break_between_august_2019_and_november_2019
    and_i_confirm_i_want_to_delete_my_break_between_august_2019_and_november_2019
    then_i_no_longer_see_my_reason_on_the_review_page
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

  def then_i_should_see_the_start_page
    expect(page).to have_current_path candidate_interface_restructured_work_history_path
  end

  def then_i_choose_that_i_have_work_history_to_add
    choose 'Yes'
    click_button 'Continue'
  end

  def and_i_click_add_a_first_job
    click_link 'Add a job'
  end

  def then_i_should_see_the_add_a_job_page
    expect(page).to have_current_path candidate_interface_new_restructured_work_history_path
  end

  def and_i_add_a_job_between_february_2015_to_august_2019
    scope = 'application_form.restructured_work_history'
    fill_in t('role.label', scope: scope), with: 'Microsoft Painter'
    fill_in t('employer.label', scope: scope), with: 'Department for Education'

    choose 'Full time'

    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '2'
      fill_in 'Year', with: '2015'
    end

    within('[data-qa="currently-working"]') do
      choose 'No'
    end

    within('[data-qa="end-date"]') do
      fill_in 'Month', with: '8'
      fill_in 'Year', with: '2019'
    end

    within('[data-qa="relevant-skills"]') do
      choose 'No'
    end

    click_button t('save_and_continue')
  end

  def then_i_click_on_add_another_job
    click_link t('application_form.work_history.another.button'), match: :first
  end

  def and_i_add_another_job_between_november_2019_and_december_2019
    scope = 'application_form.restructured_work_history'
    fill_in t('role.label', scope: scope), with: 'Junior Developer'
    fill_in t('employer.label', scope: scope), with: 'Department for Education'

    choose 'Full time'

    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '11'
      fill_in 'Year', with: '2019'
    end

    within('[data-qa="currently-working"]') do
      choose 'No'
    end

    within('[data-qa="end-date"]') do
      fill_in 'Month', with: '12'
      fill_in 'Year', with: '2019'
    end

    within('[data-qa="relevant-skills"]') do
      choose 'No'
    end

    click_button t('save_and_continue')
  end

  def then_i_see_a_two_months_break_between_my_first_job_and_my_second_job
    expect(page).to have_content('You have a break in your work history (2 months)')
  end

  def and_i_see_a_one_month_break_between_my_second_job_and_now
    expect(page).to have_content('You have a break in your work history (1 month)')
  end

  def and_i_cannot_mark_this_section_as_complete
    check t('application_form.work_history.review.completed_checkbox')
    click_button t('save_and_continue')
    expect(page).to have_content 'You cannot mark this section complete with unexplained work breaks.'
    expect(current_candidate.current_application).not_to be_work_history_completed
  end

  def then_i_see_the_start_and_end_date_filled_in_for_my_break_between_august_2019_and_november_2019
    then_i_see_the_start_and_end_date_filled_for_adding_another_job_between_august_2019_and_november_2019
  end

  def then_i_see_the_start_and_end_date_filled_for_adding_another_job_between_august_2019_and_november_2019
    expect(page).to have_selector("input[value='8']")
    expect(page).to have_selector("input[value='2019']")
    expect(page).to have_selector("input[value='11']")
    expect(page).to have_selector("input[value='2019']")
  end

  def given_i_am_on_review_work_history_page
    visit candidate_interface_restructured_work_history_review_path
  end

  def when_i_click_to_explain_my_break_between_august_2019_and_november_2019
    click_link 'add a reason for this break', match: :first
  end

  def when_i_enter_a_reason_for_my_break_between_august_2019_and_november_2019
    fill_in 'Enter reasons for break in work history', with: 'Painting is tiring.'

    click_button t('continue')
  end

  def then_i_see_my_reason_for_my_break_between_august_2019_and_november_2019_on_the_review_page
    expect(page).to have_content('Painting is tiring.')
  end

  def when_i_click_to_delete_my_break_between_august_2019_and_november_2019
    click_link 'Delete entry for break between Aug 2019 and Nov 2019'
  end

  def and_i_confirm_i_want_to_delete_my_break_between_august_2019_and_november_2019
    click_button 'Yes I’m sure - delete this entry'
  end

  def then_i_no_longer_see_my_reason_on_the_review_page
    expect(page).not_to have_content('Painting is tiring.')
  end

  def when_i_click_to_change_my_reason_for_my_break_between_august_2019_and_november_2019
    click_link 'Change entry for break between Aug 2019 and Nov 2019'
  end

  def and_i_change_my_reason_for_my_break_between_august_2019_and_november_2019
    fill_in 'Enter reasons for break in work history', with: 'Some updated reason about painting.'

    click_button t('continue')
  end

  def then_i_see_my_updated_reason_for_my_break_between_august_2019_and_november_2019_on_the_review_page
    expect(page).to have_content('Some updated reason about painting.')
  end
end
