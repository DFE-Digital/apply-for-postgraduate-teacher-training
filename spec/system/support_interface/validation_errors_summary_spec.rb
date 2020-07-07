require 'rails_helper'

RSpec.feature 'Validation errors summary' do
  include CandidateHelper
  include DfESignInHelpers

  around do |example|
    Timecop.freeze(Time.zone.local(2020, 4, 24, 12, 35, 46)) do
      example.run
    end
  end

  scenario 'Review validation error summary' do
    given_i_am_a_candidate
    and_the_track_validation_errors_feature_is_on
    and_i_enter_invalid_contact_details

    given_i_am_a_support_user

    when_i_navigate_to_the_validation_errors_summary_page
    then_i_should_see_numbers_for_the_past_week
    and_i_should_see_numbers_for_the_past_month
    and_i_should_see_numbers_for_all_time

    when_i_click_on_a_row
    then_i_should_see_the_search_page
  end

  def given_i_am_a_candidate
    create_and_sign_in_candidate
  end

  def and_the_track_validation_errors_feature_is_on
    FeatureFlag.activate('track_validation_errors')
  end

  def and_i_enter_invalid_contact_details
    visit candidate_interface_application_form_path
    click_link t('page_titles.contact_details')
    fill_in t('application_form.contact_details.phone_number.label'), with: 'ABCDEF'
    click_button t('application_form.contact_details.base.button')
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_navigate_to_the_validation_errors_summary_page
    visit support_interface_path
    click_link 'Performance'
    click_link 'Validation errors summary'
  end

  def then_i_should_see_numbers_for_the_past_week
    @validation_error = ValidationError.last
    pending 'add assertion'
  end

  def and_i_should_see_numbers_for_the_past_month
  end

  def and_i_should_see_numbers_for_all_time
  end

  def when_i_click_on_a_row
  end

  def then_i_should_see_the_search_page
  end
end
