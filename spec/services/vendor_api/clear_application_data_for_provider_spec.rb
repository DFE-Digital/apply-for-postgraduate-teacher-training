require 'rails_helper'

RSpec.describe VendorAPI::ClearApplicationDataForProvider do
  include CourseOptionHelpers

  describe '.call' do
    let(:provider) { create(:provider) }

    it 'deletes a candidate if the course on their application is associated to the provider' do
      create(
        :application_choice,
        :awaiting_provider_decision,
        course_option: course_option_for_provider(provider: provider),
      )

      expect { described_class.call(provider) }.to change { Candidate.count }.from(1).to(0)
    end

    it 'deletes a candidate if the course on an application is associated to the accredited provider' do
      create(
        :application_choice,
        :awaiting_provider_decision,
        course_option: course_option_for_accredited_provider(
          accredited_provider: provider,
          provider: create(:provider),
        ),
      )

      expect { described_class.call(provider) }.to change { Candidate.count }.from(1).to(0)
    end

    it 'deletes all associated application choices to the candidate' do
      create(
        :application_choice,
        :awaiting_provider_decision,
        course_option: course_option_for_provider(provider: provider),
      )

      expect { described_class.call(provider) }.to change { ApplicationChoice.count }.from(1).to(0)
    end

    it 'deletes all associated application forms to the candidate' do
      create(
        :application_choice,
        :awaiting_provider_decision,
        course_option: course_option_for_provider(provider: provider),
      )

      expect { described_class.call(provider) }.to change { ApplicationForm.count }.from(1).to(0)
    end
  end
end