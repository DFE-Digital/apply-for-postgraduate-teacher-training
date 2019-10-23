require 'rails_helper'

RSpec.describe AuthenticationMailer, type: :mailer do
  subject(:mailer) { described_class }

  describe '.sign_up_email' do
    let(:token) { 'blub' }
    let(:mail) { mailer.sign_up_email(to: 'test@example.com', token: token) }

    before { mail.deliver_now }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('authentication.sign_up.email.subject'))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include(t('authentication.sign_up.email.subject'))
    end

    it 'sends an email with a magic link' do
      expect(mail.body.encoded).to include("http://localhost:3000/candidate/application?token=#{token}")
    end
  end

  describe 'the candidate receives the sign in email containing the magic link' do
    let(:token) { 'blub' }
    let(:mail) { mailer.sign_in_email(to: 'test@example.com', token: token) }

    before { mail.deliver_now }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('authentication.sign_in.email.subject'))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include(t('authentication.sign_in.email.subject'))
    end

    it 'sends an email with a magic link' do
      expect(mail.body.encoded).to include("http://localhost:3000/candidate/application?token=#{token}")
    end
  end
end
