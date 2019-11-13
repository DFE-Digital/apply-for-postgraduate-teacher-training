require 'rails_helper'

RSpec.describe RefereeMailer, type: :mailer do
  subject(:mailer) { described_class }

  describe 'Send request reference email' do
    let(:application_form) { build(:completed_application_form) }
    let(:reference) { application_form.references.first }
    let(:candidate_name) { "#{application_form.first_name} #{application_form.last_name}" }
    let(:mail) { mailer.reference_request_email(application_form, reference) }

    before { mail.deliver_now }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('reference_request.email.subject', candidate_name: candidate_name))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include("provide a reference for #{candidate_name}")
    end

    it 'sends an email with a link to a prefilled Google form' do
      body = mail.body.encoded
      expect(body).to include(t('reference_request.google_form_url'))
      expect(body).to include("=#{reference.id}")
      expect(body).to include("=#{CGI.escape(reference.email_address)}")
      # TODO: Referee name
    end

    it 'encodes spaces as %20 rather than + in the Google form parameters for correct prefilling' do
      expect(mail.body.encoded).to include("=#{candidate_name.gsub(' ', '%20')}")
    end
  end
end
