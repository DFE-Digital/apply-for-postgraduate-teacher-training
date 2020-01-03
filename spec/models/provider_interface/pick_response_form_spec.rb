require 'rails_helper'

RSpec.describe ProviderInterface::PickResponseForm do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:decision).with_message('Select a response to send to the candidate') }
  end
end
