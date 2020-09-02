require 'rails_helper'

RSpec.describe ProviderInterface::SortApplicationChoices do
  describe '#call' do
    it 'sorts the application choics by RBD date if the RBD date is in the future' do
      Timecop.freeze(2020, 1, 1) do
        choice_one = create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 2.days.from_now.end_of_day)
        choice_two = create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 1.day.from_now.end_of_day)

        expect(described_class.call(application_choices: ApplicationChoice.all)).to eq [choice_two, choice_one]
      end
    end

    it 'sorts the application choices by last_changed if the RBD date is in the past' do
      Timecop.freeze(2020, 1, 1) do
        choice_one = create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 2.days.ago.end_of_day)
        choice_two = create(:application_choice, :awaiting_provider_decision, reject_by_default_at: 1.day.ago.end_of_day)

        expect(described_class.call(application_choices: ApplicationChoice.all)).to eq [choice_one, choice_two]
      end
    end
  end
end
