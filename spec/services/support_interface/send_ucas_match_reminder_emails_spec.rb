require 'rails_helper'

RSpec.describe SupportInterface::SendUCASMatchReminderEmails do
  describe '#call' do
    let(:application_choice) { create(:application_choice, :with_accepted_offer) }
    let(:application_form) { create(:completed_application_form, application_choices: [application_choice]) }
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    it 'raises an error if a reminder email was already sent' do
      ucas_match = create(:ucas_match, action_taken: 'reminder_emails_sent')

      expect {
        SupportInterface::SendUCASMatchReminderEmails.new(ucas_match).call
      }.to raise_error('Reminder email was already sent')
    end

    it 'raises an error when reminder email was not sent' do
      ucas_match = create(:ucas_match, action_taken: nil)

      expect {
        SupportInterface::SendUCASMatchReminderEmails.new(ucas_match).call
      }.to raise_error('Cannot send reminder email before sending an initial one')
    end

    context 'when the application has been accepted on both Apply and UCAS' do
      it 'sends the candidate the reminder ucas match email for multiple acceptances' do
        ucas_match = create(:ucas_match,
                            ucas_status: :pending_conditions,
                            application_form: application_form,
                            action_taken: 'initial_emails_sent',
                            candidate_last_contacted_at: 6.business_days.before(Time.zone.now))
        allow(ucas_match).to receive(:application_for_the_same_course_in_progress_on_both_services?).and_return(false)
        allow(ucas_match).to receive(:application_accepted_on_ucas_and_accepted_on_apply?).and_return(true)

        allow(CandidateMailer).to receive(:ucas_match_reminder_email_multiple_acceptances).and_return(mail)
        described_class.new(ucas_match).call

        expect(CandidateMailer).to have_received(:ucas_match_reminder_email_multiple_acceptances).with(ucas_match)
      end
    end

    context 'when the candidate applied for the same course on both Apply and UCAS' do
      it 'sends the candidate the reminder ucas match email for the duplicate application' do
        ucas_match = create(:ucas_match,
                            scheme: 'B',
                            application_form: application_form,
                            action_taken: 'initial_emails_sent',
                            candidate_last_contacted_at: 6.business_days.before(Time.zone.now))
        allow(ucas_match).to receive(:application_for_the_same_course_in_progress_on_both_services?).and_return(true)
        allow(ucas_match).to receive(:application_accepted_on_ucas_and_accepted_on_apply?).and_return(false)

        allow(CandidateMailer).to receive(:ucas_match_reminder_email_duplicate_applications).and_return(mail)
        described_class.new(ucas_match).call

        expect(CandidateMailer).to have_received(:ucas_match_reminder_email_duplicate_applications).with(application_choice, ucas_match)
      end
    end
  end
end
