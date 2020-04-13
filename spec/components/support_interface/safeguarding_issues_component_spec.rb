require 'rails_helper'

RSpec.describe SupportInterface::SafeguardingIssuesComponent do
  context 'when the candidate has shared information related to safeguarding' do
    it 'displays the correct text' do
      application_form = build_stubbed(:application_form, safeguarding_issues: 'I have a criminal conviction.')

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include(described_class::HAS_DISCLOSED_MESSAGE)
    end
  end

  context 'when the candidate has not shared information related to safeguarding' do
    it 'displays the correct text' do
      application_form = build_stubbed(:application_form, safeguarding_issues: 'No')

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include(described_class::NO_INFO_MESSAGE)
    end
  end

  context 'when the candidate has not answered the safeguarding question' do
    it 'displays the correct text' do
      application_form = build_stubbed(:application_form, safeguarding_issues: nil)

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include(described_class::NO_ANSWER_MESSAGE)
    end
  end
end
