require 'rails_helper'

describe 'A candidate signing up' do
  include TestHelpers::SignUp

  context 'who successfully signs up' do
    before do
      visit '/'
      click_on t('application_form.begin_button')
      fill_in_sign_up
    end

    it 'sees the check your email page' do
      expect(page).to have_content t('authentication.check_your_email')
    end

    it 'receives an email with a valid magic link' do
      open_email('april@pawnee.com')
      current_email.find_css('a').first.click

      expect(page).to have_content 'april@pawnee.com'
    end
  end

  context 'who tries to sign up twice' do
    it 'sees the form error summary' do
      visit '/sign-up'
      fill_in_sign_up
      visit '/sign-up'
      fill_in_sign_up

      expect(page).to have_content 'There is a problem'
    end
  end

  context 'who clicks a link with an invalid token' do
    it 'sees the start page' do
      visit '/personal-details/new?token=meow'

      expect(page.current_url).to eq(root_url)
    end
  end
end
