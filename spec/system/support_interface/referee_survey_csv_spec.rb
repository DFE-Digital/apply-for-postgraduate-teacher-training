require 'rails_helper'

RSpec.feature 'Referee survery CSV' do
  include DfESignInHelpers

  scenario 'support user can download a CSV with the survey results' do
    given_i_am_a_support_user
    and_there_are_referee_survey_results

    when_i_visit_the_service_performance_page
    and_i_click_on_download_referee_survey_results
    then_i_should_be_able_to_download_a_csv
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_referee_survey_results
    create_list(:reference, 3, :complete)
  end

  def when_i_visit_the_service_performance_page
    visit support_interface_performance_path
  end

  def and_i_click_on_download_referee_survey_results
    click_link 'Download referee survey results (CSV)'
  end

  def then_i_should_be_able_to_download_a_csv
    expect(page).to have_content ApplicationReference.first.name
    expect(page).to have_content ApplicationReference.second.name
    expect(page).to have_content ApplicationReference.third.name
  end
end
