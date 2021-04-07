require 'rails_helper'

RSpec.feature 'Cookie banner' do
  include ActionView::Helpers::DateHelper

  scenario 'Provider rejects cookies' do
    given_i_am_on_the_start_page
    and_i_can_see_the_cookie_banner
    when_i_reject_cookies
    then_i_can_no_longer_see_the_cookie_banner
    and_i_can_see_that_cookies_have_been_rejected
    when_i_hide_the_cookies_confirmation_message
    then_i_can_no_longer_see_the_cookies_confirmation_message
  end

  def given_i_am_on_the_start_page
    visit '/provider'
  end

  def and_i_can_see_the_cookie_banner
    expect(page).to have_content('Cookies on Manage teacher training applications')
  end

  def when_i_reject_cookies
    click_on 'Reject analytics cookies'
  end

  def and_i_can_see_that_cookies_have_been_rejected
    expect(page).to have_content('You’ve rejected analytics cookies.')
  end

  def when_i_hide_the_cookies_confirmation_message
    click_on 'Hide this message'
  end

  def then_i_can_no_longer_see_the_cookie_banner
    expect(page).not_to have_content('Cookies on Manage teacher training applications')
  end

  def then_i_can_no_longer_see_the_cookies_confirmation_message
    expect(page).not_to have_content('You’ve rejected analytics cookies.')
  end
end
