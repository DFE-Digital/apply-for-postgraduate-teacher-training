require 'rails_helper'

RSpec.feature 'See Duplicate candidate matches' do
  include DfESignInHelpers

  scenario 'Support agent visits Duplicate candidate matches page', sidekiq: true do
    given_i_am_a_support_user
    and_i_go_to_duplicate_candidate_matches_page
    then_i_should_see_a_message_declaring_that_there_are_no_matches

    and_there_are_candidates_with_duplicate_applications_in_the_system
    when_i_go_to_duplicate_candidate_matches_page
    then_i_should_see_list_of_duplicate_candidate_matches
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def then_i_should_see_a_message_declaring_that_there_are_no_matches
    expect(page).to have_content 'There are currently no duplicate applications matched on these criteria'
  end

  def and_there_are_candidates_with_duplicate_applications_in_the_system
    @candidate_one = create(:candidate, email_address: 'exemplar1@example.com')
    @candidate_two = create(:candidate, email_address: 'exemplar2@example.com')

    @application_form_one = create(:application_form, candidate: @candidate_one, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: Time.zone.now - 7.days)
    @application_form_two = create(:application_form, candidate: @candidate_two, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: Time.zone.now - 7.days)
  end

  def when_i_go_to_duplicate_candidate_matches_page
    visit support_interface_duplicate_candidate_matches_path
  end

  alias_method :and_i_go_to_duplicate_candidate_matches_page, :when_i_go_to_duplicate_candidate_matches_page

  def then_i_should_see_list_of_duplicate_candidate_matches
    expect(page).to have_content 'Jeffrey'
    expect(page).to have_content 'Joffrey'
    expect(page).to have_content 'Thompson'
    expect(page).to have_content '1998-08-08'
    expect(page).to have_content 'W6 9BH'
    expect(page).to have_content @candidate_one.email_address
    expect(page).to have_content @candidate_two.email_address
  end
end
