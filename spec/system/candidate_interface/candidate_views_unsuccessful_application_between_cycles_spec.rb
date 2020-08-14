require 'rails_helper'

RSpec.feature 'Candidate with unsuccessful application' do
  include CandidateHelper

  around do |example|
    Timecop.freeze(Time.zone.local(2020, 9, 25, 8, 56, 0)) do
      example.run
    end
  end

  scenario 'Sees between cycles banner and cannot apply again' do
    given_i_am_signed_in_as_a_candidate
    and_i_have_an_unsuccessful_application
    and_i_visit_the_application_dashboard
    then_i_do_not_see_an_apply_again_banner
    and_i_do_see_a_reopen_banner
  end

  def given_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_unsuccessful_application
    @application_form = create(
      :completed_application_form,
      :with_completed_references,
      references_count: 2,
      with_gces: true,
      candidate: @candidate,
      safeguarding_issues_status: :no_safeguarding_issues_to_declare,
    )
    create(:application_choice, status: :rejected, application_form: @application_form)
  end

  def and_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def then_i_do_not_see_an_apply_again_banner
    expect(page).not_to have_content('Do you want to apply again?')
  end

  def and_i_do_see_a_reopen_banner
    expect(page).to have_content('Applications for courses starting this academic year have now closed')
  end
end
