require 'rails_helper'

# To avoid this test becoming too large, only use this spec to test complex
# logic in the presenter. For anything that is passed straight from the database
# to the API, make sure that spec/system/vendor_api/vendor_receives_application_spec.rb is updated.
RSpec.describe VendorAPI::SingleApplicationPresenter do
  describe 'attributes.withdrawal' do
    it 'returns a withdrawal object' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'British', second_nationality: 'American')
      application_choice = create(:application_choice, status: 'withdrawn', application_form: application_form, withdrawn_at: '2019-01-01')

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:withdrawal]).to eq(reason: nil, date: '2019-01-01T00:00:00+00:00')
    end
  end

  describe 'attributes.rejection' do
    it 'returns a rejection object' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'British', second_nationality: 'American')
      application_choice = create(:application_choice, status: 'rejected', application_form: application_form, rejected_at: '2019-01-01', rejection_reason: 'Course full')

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:rejection]).to eq(reason: 'Course full')
    end
  end

  describe 'attributes.rejection with a withdrawn offer' do
    it 'returns a rejection object' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'British', second_nationality: 'American')
      application_choice = create(:application_choice, status: 'rejected', application_form: application_form, offer_withdrawn_at: '2019-01-01', offer_withdrawal_reason: 'Course full')

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

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
      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json
      expect(response.dig(:attributes, :hesa_itt_data)).to be_nil
    end

    it 'becomes available once application status is \'enrolled\'' do
      application_choice.update(status: 'enrolled')
      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json
      expect(response.dig(:attributes, :hesa_itt_data)).not_to be_nil
      expect(response.to_json).to be_valid_against_openapi_schema('Application')
    end
  end

  describe 'attributes.work_history_break_explanation' do
    let(:february2019) { Time.zone.local(2019, 2, 1) }
    let(:april2019) { Time.zone.local(2019, 4, 1) }
    let(:september2019) { Time.zone.local(2019, 9, 1) }
    let(:december2019) { Time.zone.local(2019, 12, 1) }

    context 'when the work history breaks field has a value' do
      it 'returns the work_history_breaks attribute of an application' do
        breaks = []
        application_form = build_stubbed(
          :completed_application_form,
          :with_completed_references,
          work_history_breaks: 'I was sleeping.',
          application_work_history_breaks: breaks,
        )
        application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

        response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

        expect(response.to_json).to be_valid_against_openapi_schema('Application')
        expect(response[:attributes][:work_experience][:work_history_break_explanation]).to eq('I was sleeping.')
      end
    end

    context 'when individual breaks have been entered' do
      it 'returns a concatentation of application_work_history_breaks of an application' do
        break1 = build_stubbed(:application_work_history_break, start_date: february2019, end_date: april2019, reason: 'I was watching TV.')
        break2 = build_stubbed(:application_work_history_break, start_date: september2019, end_date: december2019, reason: 'I was playing games.')
        breaks = [break1, break2]
        application_form = build_stubbed(
          :completed_application_form,
          :with_completed_references,
          work_history_breaks: nil,
          application_work_history_breaks: breaks,
        )
        application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

        response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

        expect(response.to_json).to be_valid_against_openapi_schema('Application')
        expect(response[:attributes][:work_experience][:work_history_break_explanation]).to eq(
          "February 2019 to April 2019: I was watching TV.\n\nSeptember 2019 to December 2019: I was playing games.",
        )
      end
    end

    context 'when no breaks have been entered' do
      it 'returns an empty string' do
        breaks = []
        application_form = build_stubbed(
          :completed_application_form,
          :with_completed_references,
          work_history_breaks: nil,
          application_work_history_breaks: breaks,
        )
        application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

        response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

        expect(response.to_json).to be_valid_against_openapi_schema('Application')
        expect(response[:attributes][:work_experience][:work_history_break_explanation]).to eq('')
      end
    end
  end

  describe 'attributes.candidate.nationality' do
    it 'compacts two nationalities with the same ISO value' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'Welsh', second_nationality: 'Scottish')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :nationality)).to eq %w[GB]
    end

    it 'returns nationality in the correct format' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'British', second_nationality: 'American')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:candidate][:nationality]).to eq(%w[GB US])
    end
  end

  describe 'attributes.candidate.contact_details' do
    it 'returns contact details in correct format for UK addresses' do
      application_form_attributes = {
        phone_number: '07700 900 982',
        address_line1: '42',
        address_line2: 'Much Wow Street',
        address_line3: 'London',
        address_line4: 'England',
        country: 'GB',
        postcode: 'SW1P 3BT',
      }
      application_form = create(
        :completed_application_form,
        :with_completed_references,
        application_form_attributes,
      )
      application_choice = create(
        :application_choice,
        status: 'awaiting_provider_decision',
        application_form: application_form,
      )

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expected_contact_details = application_form_attributes.merge(email: application_form.candidate.email_address)
      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response.dig(:attributes, :contact_details)).to eq expected_contact_details
    end

    it 'returns contact details in correct format for international addresses' do
      application_form_attributes = {
        phone_number: '07700 900 982',
        address_type: 'international',
        international_address: '456 Marine Drive, Mumbai',
        country: 'IN',
      }
      application_form = create(
        :completed_application_form,
        :with_completed_references,
        application_form_attributes,
      )
      application_choice = create(
        :application_choice,
        status: 'awaiting_provider_decision',
        application_form: application_form,
      )

      FeatureFlag.activate(:international_addresses)
      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response.dig(:attributes, :contact_details)).to eq({
        phone_number: '07700 900 982',
        address_line1: '456 Marine Drive, Mumbai',
        country: 'IN',
        email: application_form.candidate.email_address,
      })
    end
  end

  describe '#as_json' do
    context 'given a relation that includes application_qualifications' do
      let(:application_choice) do
        create(:application_choice, status: 'awaiting_provider_decision', application_form: create(:completed_application_form))
      end

      let(:given_relation) { GetApplicationChoicesForProviders.call(providers: application_choice.provider) }
      let!(:presenter) { VendorAPI::SingleApplicationPresenter.new(given_relation.first) }

      it 'does not trigger any additional queries' do
        expect { presenter.as_json }.not_to make_database_queries
      end
    end
  end
end
