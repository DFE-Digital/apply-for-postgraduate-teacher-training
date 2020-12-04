require 'rails_helper'

RSpec.describe SupportInterface::UCASMatchActionComponent do
  context 'when there is no dual application or dual acceptance' do
    it 'renders `No action required`' do
      ucas_match_without_dual_applications = create(:ucas_match, matching_state: 'new_match', scheme: 'U', ucas_status: :rejected)
      allow(ucas_match_without_dual_applications).to receive(:dual_application_or_dual_acceptance?).and_return(false)

      result = render_inline(described_class.new(ucas_match_without_dual_applications))
      expect(result.text).to include('No action required')
    end
  end

  context 'when there is a dual application or dual acceptance' do
    it 'renders correct information for a new match' do
      ucas_match = create(:ucas_match, matching_state: 'new_match', scheme: 'U', candidate_last_contacted_at: nil)
      allow(ucas_match).to receive(:dual_application_or_dual_acceptance?).and_return(true)

      result = render_inline(described_class.new(ucas_match))

      expect(result.text).to include('Action needed Send initial emails')
      expect(result.css('input').attr('value').value).to include('Send emails')
      expect(result.css('form').attr('action').value).to include('/send-initial-emails')
      expect(result.text).to include('We need to contact the candidate and the provider.')
    end

    it 'renders correct information after sending the initial emails' do
      Timecop.freeze(Time.zone.local(2020, 10, 19, 12, 0, 0)) do
        ucas_match = create(:ucas_match,
                            matching_state: 'new_match',
                            scheme: 'U',
                            action_taken: 'initial_emails_sent',
                            candidate_last_contacted_at: Time.zone.now - 1.day)
        allow(ucas_match).to receive(:dual_application_or_dual_acceptance?).and_return(true)

        result = render_inline(described_class.new(ucas_match))

        expect(result.text).to include('No action required')
        expect(result.text).to include('We sent the initial emails on the 18 October 2020')
      end
    end

    it 'renders correct information when reminder emails need to be send' do
      Timecop.freeze(Time.zone.local(2020, 10, 19, 12, 0, 0)) do
        ucas_match = create(:ucas_match,
                            matching_state: 'new_match',
                            scheme: 'U',
                            action_taken: 'initial_emails_sent',
                            candidate_last_contacted_at: Time.zone.now - 7.days)
        allow(ucas_match).to receive(:dual_application_or_dual_acceptance?).and_return(true)

        result = render_inline(described_class.new(ucas_match))

        expect(result.text).to include('Action needed Send a reminder email')
        expect(result.css('input').attr('value').value).to include('Send a reminder email')
        expect(result.css('form').attr('action').value).to include('/send-reminder-email')
        expect(result.text).to include('We need to contact the candidate again')
      end
    end

    it 'renders correct information after sending the reminder emails' do
      Timecop.freeze(Time.zone.local(2020, 10, 19, 12, 0, 0)) do
        ucas_match = create(:ucas_match,
                            matching_state: 'new_match',
                            scheme: 'U',
                            action_taken: 'reminder_emails_sent',
                            candidate_last_contacted_at: Time.zone.now - 1.day)
        allow(ucas_match).to receive(:dual_application_or_dual_acceptance?).and_return(true)

        result = render_inline(described_class.new(ucas_match))

        expect(result.text).to include('No action required')
        expect(result.text).to include('We sent the reminder emails on the 18 October 2020')
      end
    end

    it 'renders correct information when withdrawal from UCAS needs to be requested' do
      Timecop.freeze(Time.zone.local(2020, 10, 19, 12, 0, 0)) do
        ucas_match = create(:ucas_match,
                            matching_state: 'new_match',
                            scheme: 'U',
                            action_taken: 'reminder_emails_sent',
                            candidate_last_contacted_at: Time.zone.now - 16.days)
        allow(ucas_match).to receive(:dual_application_or_dual_acceptance?).and_return(true)

        result = render_inline(described_class.new(ucas_match))

        expect(result.text).to include('Action needed Request withdrawal from UCAS')
        expect(result.css('input').attr('value').value).to include('Confirm withdrawal from UCAS was requested')
        expect(result.css('form').attr('action').value).to include('/record-ucas-withdrawal-requested')
        expect(result.text).to include('We need to contact UCAS')
      end
    end

    it 'renders correct information after requesting withdrawal from UCAS' do
      Timecop.freeze(Time.zone.local(2020, 10, 19, 12, 0, 0)) do
        ucas_match = create(:ucas_match,
                            matching_state: 'new_match',
                            scheme: 'U',
                            action_taken: 'ucas_withdrawal_requested',
                            candidate_last_contacted_at: Time.zone.now - 1.day)
        allow(ucas_match).to receive(:dual_application_or_dual_acceptance?).and_return(true)

        result = render_inline(described_class.new(ucas_match))

        expect(result.text).to include('No action required')
        expect(result.text).to include(' We requested withdrawal from UCAS on the 18 October 2020 at 12:00p')
      end
    end

    it 'renders correct information after UCAS resolution of a match' do
      Timecop.freeze(Time.zone.local(2020, 10, 19, 12, 0, 0)) do
        ucas_match = create(:ucas_match,
                            matching_state: 'processed',
                            scheme: 'U',
                            action_taken: 'resolved_on_ucas',
                            candidate_last_contacted_at: Time.zone.now - 1.day)
        allow(ucas_match).to receive(:dual_application_or_dual_acceptance?).and_return(true)

        result = render_inline(described_class.new(ucas_match))

        expect(result.text).to include('No action required')
        expect(result.text).to include('We confirmed that the candidate was withdrawn from UCAS on the 18 October 2020')
      end
    end

    it 'renders correct information after Apply resolution of a match' do
      Timecop.freeze(Time.zone.local(2020, 10, 19, 12, 0, 0)) do
        ucas_match = create(:ucas_match,
                            matching_state: 'processed',
                            scheme: 'U',
                            action_taken: 'resolved_on_apply',
                            candidate_last_contacted_at: Time.zone.now - 1.day)
        allow(ucas_match).to receive(:dual_application_or_dual_acceptance?).and_return(true)

        result = render_inline(described_class.new(ucas_match))

        expect(result.text).to include('No action required')
        expect(result.text).to include('We confirmed that the candidate was withdrawn from Apply on the 18 October 2020')
      end
    end
  end
end
