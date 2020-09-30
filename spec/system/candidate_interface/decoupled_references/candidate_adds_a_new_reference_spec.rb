require 'rails_helper'

RSpec.feature 'Candidate application choices are delivered to providers' do
  include CandidateHelper

  scenario 'the candidate receives an email' do
    given_i_am_signed_in
    and_the_decoupled_references_flag_is_on

    when_i_visit_the_site
    then_i_should_see_the_decoupled_references_section

    when_i_click_add_you_references
    then_i_see_the_start_page

    when_i_click_continue
    then_i_see_the_type_page
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_decoupled_references_flag_is_on
    FeatureFlag.activate('decoupled_references')
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def then_i_should_see_the_decoupled_references_section
    expect(page).to have_content 'It takes 8 days to get a reference on average.'
  end

  def when_i_click_add_you_references
    click_link 'Add your references'
  end

  def then_i_see_the_start_page
    expect(page).to have_current_path candidate_interface_decoupled_referees_start_path
  end

  def when_i_click_continue
    click_link 'Continue'
  end

  def then_i_see_the_type_page
    expect(page).to have_current_path candidate_interface_decoupled_referees_type_path
  end
end
