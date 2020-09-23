require 'rails_helper'

RSpec.describe CandidateInterface::EnglishForeignLanguage::IeltsReviewComponent, type: :component do
  it 'renders a review summary for an IELTS qualification' do
    ielts_qualification = build(
      :ielts_qualification,
      trf_number: '111111',
      award_year: '2001',
      band_score: '8',
    )
    result = render_inline(described_class.new(ielts_qualification))

    [
      { position: 0, title: 'Have you done an English as a foreign language assessment?', value: 'Yes' },
      { position: 1, title: 'Type of assessment', value: 'IELTS' },
      { position: 2, title: 'Test report form (TRF) number', value: '111111' },
      { position: 3, title: 'Year completed', value: '2001' },
      { position: 4, title: 'Overall band score', value: '8' },
    ].each do |row|
      expect(result.css('.govuk-summary-list__key')[row[:position]].text).to include(row[:title])
      expect(result.css('.govuk-summary-list__value')[row[:position]].text).to include(row[:value])
    end
  end
end
