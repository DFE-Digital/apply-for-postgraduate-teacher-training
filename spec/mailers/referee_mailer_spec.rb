require 'rails_helper'

RSpec.describe RefereeMailer, type: :mailer do
  subject(:mailer) { described_class }

  describe 'Send request reference email' do
    let(:first_application_choice) { create(:application_choice) }
    let(:second_application_choice) { create(:application_choice) }
    let(:third_application_choice) { create(:application_choice) }
    let(:application_form) do
      create(
        :completed_application_form,
        first_name: 'Harry',
        last_name: "O'Potter",
        application_choices_count: 0,
        application_choices: [
          first_application_choice,
          second_application_choice,
          third_application_choice,
        ],
      )
    end
    let(:reference) { application_form.references.first }
    let(:candidate_name) { "#{application_form.first_name} #{application_form.last_name}" }
    let(:mail) { mailer.reference_request_email(application_form, reference) }

    before { mail.deliver_now }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('reference_request.subject.initial', candidate_name: candidate_name))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include("Give a reference for #{candidate_name}")
    end

    it 'sends an email with the correct courses listed' do
      expect(mail.body.encoded).to include("#{first_application_choice.provider.name} - #{first_application_choice.course.name}")
      expect(mail.body.encoded).to include("#{second_application_choice.provider.name} - #{second_application_choice.course.name}")
      expect(mail.body.encoded).to include("#{third_application_choice.provider.name} - #{third_application_choice.course.name}")
    end

    it 'sends an email with a link to the reference page' do
      body = mail.body.encoded
      expect(body).to include(candidate_interface_reference_comments_url(token: '1234567890'))
    end
  end

  describe 'Send chasing reference email' do
    let(:first_application_choice) { create(:application_choice) }
    let(:second_application_choice) { create(:application_choice) }
    let(:third_application_choice) { create(:application_choice) }
    let(:application_form) do
      create(
        :completed_application_form,
        first_name: 'Harry',
        last_name: 'Potter',
        application_choices_count: 0,
        application_choices: [
          first_application_choice,
          second_application_choice,
          third_application_choice,
        ],
      )
    end
    let(:reference) { application_form.references.first }
    let(:candidate_name) { "#{application_form.first_name} #{application_form.last_name}" }
    let(:mail) { mailer.reference_request_chaser_email(application_form, reference) }

    before { mail.deliver_now }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('reference_request.subject.chaser', candidate_name: candidate_name))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include("Give a reference for #{candidate_name}")
    end

    it 'sends an email with the correct courses listed' do
      expect(mail.body.encoded).to include("#{first_application_choice.provider.name} - #{first_application_choice.course.name}")
      expect(mail.body.encoded).to include("#{second_application_choice.provider.name} - #{second_application_choice.course.name}")
      expect(mail.body.encoded).to include("#{third_application_choice.provider.name} - #{third_application_choice.course.name}")
    end

    it 'sends an email with a link to a prefilled Google form' do
      body = mail.body.encoded
      expect(body).to include(t('reference_request.google_form_url'))
      expect(body).to include("=#{reference.id}")
      expect(body).to include("=#{CGI.escape(reference.email_address)}")
    end

    it 'encodes spaces as %20 rather than + in the Google form parameters for correct prefilling' do
      expect(mail.body.encoded).to include("=#{candidate_name.gsub(' ', '%20')}")
      expect(mail.body.encoded).to include("=#{reference.name.gsub(' ', '%20')}")
    end

    context 'an email containing a +' do
      let(:reference) { build(:reference, email_address: 'email+email@email.com') }

      it 'does not strip the plus from the email address' do
        expect(mail.body.encoded).to include("=#{CGI.escape('email+email@email.com')}")
      end
    end
  end
end
