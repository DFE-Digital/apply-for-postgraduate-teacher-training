require 'rails_helper'

RSpec.describe SendApplicationToProvider do
  let(:application_choice) do
    create(
      :application_choice,
      status: 'application_complete',
      edit_by: 2.business_days.ago,
    )
  end

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  it 'sets the status to `awaiting_provider_decision`' do
    SendApplicationToProvider.new(application_choice: application_choice).call

    expect(application_choice.reload.status).to eq 'awaiting_provider_decision'
  end

  it 'sets the `reject_by_default_at` date and `reject_by_default_days`' do
    reject_by_default_at = 20.business_days.from_now.end_of_day
    time_limit_calculator = instance_double(TimeLimitCalculator, call: [20, reject_by_default_at])
    allow(TimeLimitCalculator).to receive(:new).and_return(time_limit_calculator)

    SendApplicationToProvider.new(application_choice: application_choice).call

    expect(application_choice.reload.reject_by_default_at.round).to eq reject_by_default_at.round
    expect(application_choice.reject_by_default_days).to eq 20
  end

  it 'sends a Slack notification' do
    allow(SlackNotificationWorker).to receive(:perform_async)

    SendApplicationToProvider.new(application_choice: application_choice).call

    expect(SlackNotificationWorker).to have_received(:perform_async)
  end
end
