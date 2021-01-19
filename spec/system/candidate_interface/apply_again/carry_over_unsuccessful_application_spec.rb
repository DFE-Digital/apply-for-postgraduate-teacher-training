require 'rails_helper'

RSpec.describe 'Candidate can carry over unsuccessful application to a new recruitment cycle' do
  around do |example|
    Timecop.freeze(Date.new(2020, 8, 1)) do
      example.run
    end
  end

  scenario 'when an unsuccessful candidate returns in the next recruitment cycle they can re-apply by carrying over their original application' do
    given_i_am_signed_in
    and_i_am_in_the_2020_recruitment_cycle
    and_i_have_an_application_with_a_rejection

    when_the_2020_recruitment_cycle_ends
    and_i_visit_my_application_complete_page
    then_i_cannot_apply_again

    when_the_2021_recruitment_cycle_begins
    and_i_visit_my_application_complete_page
    and_i_click_on_apply_again
    and_i_click_on_start_now
    and_i_click_go_to_my_application_form

    then_i_can_see_application_details
    and_i_can_see_that_no_courses_are_selected

    when_i_visit_the_carry_over_page_again
    then_i_am_redirected_to_my_existing_application
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_am_in_the_2020_recruitment_cycle
    allow(RecruitmentCycle).to receive(:current_year).and_return(2020)
  end

  def and_i_have_an_application_with_a_rejection
    @application_form = create(:completed_application_form, :with_completed_references, candidate: @candidate)
    create(:application_choice, :with_rejection, application_form: @application_form)
  end

  def when_the_2020_recruitment_cycle_ends
    Timecop.safe_mode = false
    Timecop.travel(Time.zone.local(2020, 9, 20, 12, 0, 0))
    allow(RecruitmentCycle).to receive(:current_year).and_return(2021)
  ensure
    Timecop.safe_mode = true
  end

  def then_i_cannot_apply_again
    expect(page).not_to have_link 'Do you want to apply again?'
  end

  def when_the_2021_recruitment_cycle_begins
    Timecop.safe_mode = false
    Timecop.travel(Time.zone.local(2020, 10, 15, 12, 0, 0))
    allow(RecruitmentCycle).to receive(:current_year).and_return(2021)
  ensure
    Timecop.safe_mode = true
  end

  def and_i_visit_my_application_complete_page
    logout
    login_as(@candidate)
    visit candidate_interface_application_complete_path
  end

  def and_i_click_on_apply_again
    expect(page).to have_content 'Do you want to continue applying?'
    click_link 'Continue your application'
  end

  def and_i_click_on_start_now
    expect(page).to have_content 'Carry on with your application for courses starting in the 2021 to 2022 academic year.'
    expect(page).to have_content 'Your courses have been removed. You can add them again now.'
    click_button 'Apply again'
  end

  def and_i_click_go_to_my_application_form
    click_link 'Go to your application form'
  end

  def then_i_can_see_application_details
    expect(page).to have_content('Personal information Completed')
    click_link 'Personal information'
    expect(page).to have_content(@application_form.full_name)
    click_button t('continue')
  end

  def and_i_can_see_that_no_courses_are_selected
    expect(page).to have_content('Choose your courses Incomplete')
    click_link 'Choose your courses'
    expect(page).to have_content 'You can apply for up to 3 courses'
  end

  def when_i_visit_the_carry_over_page_again
    visit candidate_interface_start_carry_over_path
  end

  def then_i_am_redirected_to_my_existing_application
    then_i_can_see_application_details
  end
end
