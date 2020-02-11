require 'rails_helper'

# To avoid this test becoming too large, only use this spec to test complex
# logic in the presenter. For anything that is passed straight from the database
# to the API, make sure that spec/system/vendor_api/vendor_receives_application_spec.rb is updated.
RSpec.describe VendorApi::SingleApplicationPresenter do
  describe 'attributes.candidate.nationality' do
    it 'returns nationality in the correct format' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'British', second_nationality: 'American')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorApi::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:candidate][:nationality]).to eq(%w[GB US])
    end
  end

  describe 'attributes.withdrawal' do
    it 'returns a withdrawal object' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'British', second_nationality: 'American')
      application_choice = create(:application_choice, status: 'withdrawn', application_form: application_form, withdrawn_at: '2019-01-01')

      response = VendorApi::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:withdrawal]).to eq(reason: nil, date: '2019-01-01T00:00:00+00:00')
    end
  end

  describe 'attributes.rejection' do
    it 'returns a rejection object' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'British', second_nationality: 'American')
      application_choice = create(:application_choice, status: 'rejected', application_form: application_form, rejected_at: '2019-01-01', rejection_reason: 'Course full')

      response = VendorApi::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:rejection]).to eq(reason: 'Course full')
    end
  end

  describe 'attributes.rejection with a withdrawn offer' do
    it 'returns a rejection object' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'British', second_nationality: 'American')
      application_choice = create(:application_choice, status: 'rejected', application_form: application_form, offer_withdrawn_at: '2019-01-01', offer_withdrawal_reason: 'Course full')

      response = VendorApi::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:rejection]).to eq(reason: 'Course full')
    end
  end

  describe 'attributes.hesa_itt_data' do
    let(:application_choice) do
      application_form = create(:completed_application_form, :with_completed_references)
      create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)
    end

    it 'is hidden by default' do
      response = VendorApi::SingleApplicationPresenter.new(application_choice).as_json
      expect(response.dig(:attributes, :hesa_itt_data)).to be_nil
    end

    it 'becomes available once application status is \'enrolled\'' do
      application_choice.update(status: 'enrolled')
      response = VendorApi::SingleApplicationPresenter.new(application_choice).as_json
      expect(response.dig(:attributes, :hesa_itt_data)).not_to be_nil
      expect(response.to_json).to be_valid_against_openapi_schema('Application')
    end
  end

  describe '#as_json' do
    context 'given a relation that includes application_qualifications' do
      let(:application_choice) do
        create(:application_choice, status: 'awaiting_provider_decision', application_form: create(:completed_application_form))
      end

      let(:given_relation) { GetApplicationChoicesForProviders.call(providers: application_choice.provider) }
      let!(:presenter) { VendorApi::SingleApplicationPresenter.new(given_relation.first) }

      it 'does not trigger any additional queries' do
        expect { presenter.as_json }.not_to make_database_queries
      end
    end
  end
end
