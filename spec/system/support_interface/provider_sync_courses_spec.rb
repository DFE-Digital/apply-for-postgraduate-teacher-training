require 'rails_helper'

RSpec.feature 'See provider course syncing' do
  include DfESignInHelpers

  scenario 'User switches provider to sync courses' do
    given_i_am_a_support_user
    and_a_provider_exists
    when_i_visit_the_providers_page
    then_i_see_that_the_provider_is_not_configured_to_sync_courses

    when_i_click_on_a_provider
    and_i_click_on_the_enable_course_syncing_button
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_a_provider_exists
    create :provider, code: 'ABC', name: 'ABC College'
  end

  def when_i_visit_the_providers_page
    visit support_interface_providers_path
  end

  def then_i_see_that_the_provider_is_not_configured_to_sync_courses
    expect(page).to have_content('Not synced from Find')
  end

  def when_i_click_on_a_provider
    click_link 'ABC College'
  end

  def and_i_click_on_the_enable_course_syncing_button
    click_button 'Enable course syncing from Find'
  end
end
