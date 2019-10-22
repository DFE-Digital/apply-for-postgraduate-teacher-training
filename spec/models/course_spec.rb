require 'rails_helper'

RSpec.describe Course, type: :model do
  subject(:course) { create(:course) }

  describe 'a valid course' do
    it { is_expected.to validate_presence_of :level }
  end
end
