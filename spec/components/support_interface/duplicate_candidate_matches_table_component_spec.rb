require 'rails_helper'

RSpec.describe SupportInterface::DuplicateCandidateMatchesTableComponent do
  let(:candidate) { create(:candidate) }
  let(:application_form) { create(:application_form, candidate: candidate) }
  let(:query1) { [] }
  let(:query2) {
    [
      {
        'candidate_id' => 25,
        'first_name' => 'Jeffrey',
        'last_name' => 'Thompson',
        'postcode' => 'W6 9BH',
        'date_of_birth' => '1998-08-08',
        'email_address' => 'exemplar1@example.com',
      },
      {
        'candidate_id' => 26,
        'first_name' => 'Joffrey',
        'last_name' => 'Thompson',
        'postcode' => 'W6 9BH',
        'date_of_birth' => '1998-08-08',
        'email_address' => 'exemplar2@example.com',
      },
    ]
  }

  it 'does not render table data when no duplicates exist' do
    result = render_inline(described_class.new(matches: query1))

    expect(result.css('td')[0]).to eq(nil)
  end

  it 'renders a row for each duplicate candidate' do
    result = render_inline(described_class.new(matches: query2))

    expect(result.css('td')[0].text).to include('25')
    expect(result.css('td')[1].text).to include('Jeffrey')
    expect(result.css('td')[2].text).to include('Thompson')
    expect(result.css('td')[3].text).to include('1998-08-08')
    expect(result.css('td')[4].text).to include('W6 9BH')
    expect(result.css('td')[5].text).to include('exemplar1@example.com')

    expect(result.css('td')[6].text).to include('26')
    expect(result.css('td')[7].text).to include('Joffrey')
    expect(result.css('td')[8].text).to include('Thompson')
    expect(result.css('td')[9].text).to include('1998-08-08')
    expect(result.css('td')[10].text).to include('W6 9BH')
    expect(result.css('td')[11].text).to include('exemplar2@example.com')
  end
end
