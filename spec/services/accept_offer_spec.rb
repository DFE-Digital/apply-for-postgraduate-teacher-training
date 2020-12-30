require 'rails_helper'

RSpec.describe AcceptOffer do
  it 'sets the accepted_at date for the application_choice' do
    application_choice = create(:application_choice, status: :offer)

    Timecop.freeze do
      expect {
        AcceptOffer.new(application_choice: application_choice).save!
      }.to change { application_choice.accepted_at }.to(Time.zone.now)
    end
  end

  describe 'emails' do
    let(:application_choice) { create(:application_choice, status: :offer) }

    around { |example| perform_enqueued_jobs(&example) }

    describe 'when provider_user notifications are on' do
      let(:provider_user) { create :provider_user, send_notifications: true, providers: [application_choice.provider] }

      it 'sends and tracks a notification email to the provider' do
        expect {
          described_class.new(application_choice: application_choice).save!
        }.to have_metrics_tracked(application_choice, 'notifications.on', provider_user, :offer_accepted)
          .and change { ActionMailer::Base.deliveries.count }.by(2)

        expect(ActionMailer::Base.deliveries.first.to).to eq [provider_user.email_address]
        expect(ActionMailer::Base.deliveries.first.subject).to match(/has accepted your offer/)
      end
    end

    describe 'when provider_user notifications are off' do
      let(:provider_user) { create :provider_user, send_notifications: false, providers: [application_choice.provider] }

      it 'tracks that a notification was sent' do
        expect {
          described_class.new(application_choice: application_choice).save!
        }.to have_metrics_tracked(application_choice, 'notifications.off', provider_user, :offer_accepted)
          .and change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    it 'sends a confirmation email to the candidate' do
      expect { described_class.new(application_choice: application_choice).save! }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(ActionMailer::Base.deliveries.first.to).to eq [application_choice.application_form.candidate.email_address]
      expect(ActionMailer::Base.deliveries.first.subject).to match(/You’ve accepted/)
    end
  end
end
