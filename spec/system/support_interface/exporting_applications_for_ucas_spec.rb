require 'rails_helper'

RSpec.feature 'Exporting applications for UCAS as CSV' do
  include DfESignInHelpers

  scenario 'support user can download a CSV with submitted applications formatted for UCAS' do
    given_i_am_a_support_user
    and_there_are_submitted_applications

    when_i_visit_the_service_performance_page
    and_i_click_on_download_dataset_1
    then_i_should_be_able_to_download_a_csv
    and_it_has_one_row_for_each_application_choice_plus_a_header_row
    and_it_has_the_expected_content
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_submitted_applications
    create_list(:completed_application_form, 3, application_choices_count: 3)
  end

  def when_i_visit_the_service_performance_page
    visit support_interface_performance_path
  end

  def and_i_click_on_download_dataset_1
    click_link 'Download Dataset 1 (CSV)'
  end

  def then_i_should_be_able_to_download_a_csv
    expect(page.response_headers['Content-Type']).to eq('text/csv')
  end

  def and_it_has_one_row_for_each_application_choice_plus_a_header_row
    expect(page.body.split("\n").size).to eq(10)
  end

  def and_it_has_the_expected_content
    applications = ApplicationForm.all
    expect(page).to have_content applications.first.candidate_id
    expect(page).to have_content applications.first.application_choices.first.course.code
    expect(page).to have_content applications.first.application_choices.second.course.code
    expect(page).to have_content applications.first.application_choices.third.course.code

    expect(page).to have_content applications[1].candidate_id
    expect(page).to have_content applications[1].application_choices.first.course.code
    expect(page).to have_content applications[1].application_choices.second.course.code
    expect(page).to have_content applications[1].application_choices.third.course.code

    expect(page).to have_content applications[2].candidate_id
    expect(page).to have_content applications[2].application_choices.first.course.code
    expect(page).to have_content applications[2].application_choices.second.course.code
    expect(page).to have_content applications[2].application_choices.third.course.code
  end
end
