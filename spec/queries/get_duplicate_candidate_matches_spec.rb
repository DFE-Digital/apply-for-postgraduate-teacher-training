require 'rails_helper'

RSpec.describe GetDuplicateCandidateMatches do
  let(:candidate1) { create(:candidate, id: '1', email_address: 'exemplar1@example.com') }
  let(:candidate2) { create(:candidate, id: '2', email_address: 'exemplar2@example.com') }

  before do
    create(:application_form, candidate: candidate1, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'w6 9bh ', submitted_at: Time.zone.now - 7.days)
    create(:application_form, candidate: candidate2, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'w6 9bh ', submitted_at: Time.zone.now - 7.days)
    create(:application_form, candidate: candidate1, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'w6 9bh ', submitted_at: Time.zone.now - 1.day)
  end

  describe '#call' do
    let(:returned_array_of_hashes) { GetDuplicateCandidateMatches.call }

    it 'returns an array of hashes with the correct keys' do
      expect(returned_array_of_hashes.count).to eq(2)
      expect(returned_array_of_hashes.first.keys).to \
        eq %w[candidate_id first_name last_name postcode date_of_birth email_address]
    end

    it 'returns an array of hashes the correct values' do
      expect(returned_array_of_hashes.first['candidate_id']).to eq(1)
      expect(returned_array_of_hashes.first['first_name']).to eq('Jeffrey')
      expect(returned_array_of_hashes.first['last_name']).to eq('Thompson')
      expect(returned_array_of_hashes.first['date_of_birth']).to eq('1998-08-08')
      expect(returned_array_of_hashes.first['postcode']).to eq('W6 9BH')
      expect(returned_array_of_hashes.first['email_address']).to eq('exemplar1@example.com')

      expect(returned_array_of_hashes.second['candidate_id']).to eq(2)
      expect(returned_array_of_hashes.second['first_name']).to eq('Joffrey')
      expect(returned_array_of_hashes.second['last_name']).to eq('Thompson')
      expect(returned_array_of_hashes.second['date_of_birth']).to eq('1998-08-08')
      expect(returned_array_of_hashes.second['postcode']).to eq('W6 9BH')
      expect(returned_array_of_hashes.second['email_address']).to eq('exemplar2@example.com')
    end
  end
end
