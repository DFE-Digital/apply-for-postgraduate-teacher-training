require 'rails_helper'

RSpec.describe RejectAwaitingReferencesCourseChoicesWorker do
  describe '#perform' do
    it 'calls the `GetAwaitingReferencesCourseChoicesForPreviousCycle` service' do
      allow(CandidateInterface::GetPreviousCyclesAwaitingReferencesCourseChoices).to receive(:call).and_return([])
      RejectAwaitingReferencesCourseChoicesWorker.new.perform

      expect(CandidateInterface::GetPreviousCyclesAwaitingReferencesCourseChoices).to have_received(:call)
    end
  end
end
