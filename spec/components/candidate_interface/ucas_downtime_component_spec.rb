require 'rails_helper'

RSpec.describe CandidateInterface::UcasDowntimeComponent do
  context 'when the banner for UCAS downtime feature flag is on' do
    it 'renders the banner' do
      FeatureFlag.activate('banner_for_ucas_downtime')

      result = render_inline(CandidateInterface::UcasDowntimeComponent.new)

      expect(result.text).to include('UCAS services won’t be available from 6pm on Friday 20 March until Sunday 22 March.')
    end
  end

  context 'when the banner for UCAS downtime feature flag is off' do
    it 'does not render the banner' do
      FeatureFlag.deactivate('banner_for_ucas_downtime')

      result = render_inline(CandidateInterface::UcasDowntimeComponent.new)

      expect(result.text).to eq('')
    end
  end
end
