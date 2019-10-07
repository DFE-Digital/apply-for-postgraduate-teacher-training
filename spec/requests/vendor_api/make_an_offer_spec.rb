require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1/applications/:id/offer', type: :request do
  include VendorApiSpecHelpers

  describe 'making a conditional offer' do
    it 'returns the updated application' do
      application_choice = create(:application_choice, provider_ucas_code: 'ABC')
      request_body = {
        "data": {
          "conditions": [
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test',
          ],
        },
      }

      post "/api/v1/applications/#{application_choice.id}/offer", params: request_body

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq('conditional_offer')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [
          'Completion of subject knowledge enhancement',
          'Completion of professional skills test',
        ],
      )
    end
  end

  describe 'making an unconditional offer' do
    it 'returns the updated application' do
      application_choice = create(:application_choice, provider_ucas_code: 'ABC')
      request_body = {}

      post "/api/v1/applications/#{application_choice.id}/offer", params: request_body

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq('unconditional_offer')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [],
      )
    end
  end

  it 'returns a not found error if the application can\'t be found' do
    request_body = {
                      "data": {
                        "conditions": [
                                  'Completion of subject knowledge enhancement',
                                  'Completion of professional skills test',
                        ],
                      },
                    }

    post '/api/v1/applications/non-existent-id/offer', params: request_body

    expect(response).to have_http_status(404)
    expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
    expect(error_response['message']).to eql('Could not find an application with ID non-existent-id')
  end
end
