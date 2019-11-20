require 'rails_helper'

RSpec.feature 'Viewing privacy policy' do
  scenario 'Candidate views the privacy policy' do
    given_i_am_on_the_start_page
    when_i_can_click_on_privacy_policy
    then_i_can_see_the_privacy_policy
  end

  def given_i_am_on_the_start_page
    visit '/'
  end

  def when_i_can_click_on_privacy_policy
    within('.govuk-footer') { click_link t('layout.privacy_policy') }
  end

  def then_i_can_see_the_privacy_policy
    expect(page).to have_content(t('page_titles.privacy_policy'))
  end
end
