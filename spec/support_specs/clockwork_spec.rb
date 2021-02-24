require 'rails_helper'
require 'clockwork/test'
require 'sidekiq'

RSpec.describe Clockwork do
  after(:each) { Clockwork::Test.clear! }

  [
    { worker: DeclineOffersByDefaultWorker, task: 'DeclineOffersByDefault' },
    { worker: SendChaseEmailToProvidersWorker, task: 'SendChaseEmailToProviders' },
    { worker: SendChaseEmailToCandidatesWorker, task: 'SendChaseEmailToCandidates' },
  ].each do |worker|
    describe 'worker schedule', clockwork: true do
      it 'runs the job every hour' do
        start_time = Time.zone.local(2020, 1, 2, 0, 0, 0)
        end_time = Time.zone.local(2020, 1, 2, 3, 0, 0)
        Clockwork::Test.run(
          start_time: start_time,
          end_time: end_time,
          tick_speed: 1.minute,
          file: './config/clock.rb',
        )
        expect(Clockwork::Test.times_run(worker[:task])).to eq 3
      end

      it 'queues a worker task' do
        allow(worker[:worker]).to receive(:perform_async)
        Clockwork::Test.run(max_ticks: 60, tick_speed: 1.minute, file: './config/clock.rb')
        Clockwork::Test.block_for(worker[:task]).call
        expect(worker[:worker]).to have_received(:perform_async)
      end
    end
  end

  it 'executes all defined jobs without error' do
    start_time = Time.now.beginning_of_day
    end_time = Time.now.end_of_day

    Clockwork::Test.run(
      start_time: start_time,
      end_time: end_time,
      tick_speed:
      1.minute, file: './config/clock.rb'
    )

    Clockwork::Test.manager.send(:history).jobs.each do |job|
      expect { Clockwork::Test.block_for(job).call }.not_to raise_error
    end
  end
end
