require 'rails_helper'

RSpec.describe AcceptUnconditionalOffer do
  include CourseOptionHelpers

  it 'sets the accepted_at date for the application_choice' do
    application_choice = build(:application_choice, status: :offer)

    Timecop.freeze do
      expect {
        described_class.new(application_choice: application_choice).save!
      }.to change { application_choice.accepted_at }.to(Time.zone.now)
    end
  end

  it 'generates an application outcome message via the state change notifier' do
    application_choice = build(:application_choice, status: :offer)
    notifier_double = instance_double(StateChangeNotifier, application_outcome_notification: true)
    allow(StateChangeNotifier).to receive(:new).with(:recruited, application_choice).and_return(notifier_double)

    described_class.new(application_choice: application_choice).save!

    expect(notifier_double).to have_received(:application_outcome_notification)
  end

  it 'returns false on state transition errors' do
    state_change_double = instance_double(ApplicationStateChange)
    allow(state_change_double).to receive(:accept_unconditional_offer!).and_raise(Workflow::NoTransitionAllowed)
    allow(ApplicationStateChange).to receive(:new).and_return(state_change_double)

    expect(described_class.new(application_choice: build(:application_choice)).save!).to be false
    expect(state_change_double).to have_received(:accept_unconditional_offer!)
  end

  describe 'emails' do
    around { |example| perform_enqueued_jobs(&example) }

    it 'sends a notification email to the training provider and ratifying provider' do
      training_provider = create(:provider)
      training_provider_user = create(:provider_user, send_notifications: true, providers: [training_provider])

      ratifying_provider = create(:provider)
      ratifying_provider_user = create(:provider_user, send_notifications: true, providers: [ratifying_provider])

      course_option = course_option_for_accredited_provider(provider: training_provider, accredited_provider: ratifying_provider)
      application_choice = build(:application_choice, :with_offer, course_option: course_option)

      expect { described_class.new(application_choice: application_choice).save! }.to change { ActionMailer::Base.deliveries.count }.by(3)
      expect(ActionMailer::Base.deliveries.first.subject).to match(/has accepted your offer/)
      expect(ActionMailer::Base.deliveries.first.to).to eq [training_provider_user.email_address]
      expect(ActionMailer::Base.deliveries.second.to).to eq [ratifying_provider_user.email_address]
    end

    it 'sends a confirmation email to the candidate' do
      application_choice = create(:application_choice, status: :offer)

      expect { described_class.new(application_choice: application_choice).save! }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(ActionMailer::Base.deliveries.first.to).to eq [application_choice.application_form.candidate.email_address]
      expect(ActionMailer::Base.deliveries.first.subject).to match(/You’ve accepted/)
    end
  end
end
