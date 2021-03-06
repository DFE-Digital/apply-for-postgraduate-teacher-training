require 'rails_helper'

RSpec.describe CandidateInterface::EnglishForeignLanguage::OtherEflQualificationReviewComponent, type: :component do
  it 'renders a review summary for the assessment' do
    other_qualification = build(
      :other_efl_qualification,
      name: 'Some English Test',
      grade: '8',
      award_year: '2001',
    )
    result = render_inline(described_class.new(other_qualification))

    [
      { position: 0, title: 'Have you done an English as a foreign language assessment?', value: 'Yes' },
      { position: 1, title: 'Type of assessment', value: 'Some English Test' },
      { position: 2, title: 'Score or grade', value: '8' },
      { position: 3, title: 'Year completed', value: '2001' },
    ].each do |row|
      expect(result.css('.govuk-summary-list__key')[row[:position]].text).to include(row[:title])
      expect(result.css('.govuk-summary-list__value')[row[:position]].text).to include(row[:value])
    end
  end
end
