require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/confirm-enrolment', type: :request do
  include VendorApiSpecHelpers

  describe 'successfully confirming enrolment' do
    it 'returns updated application' do
      application_choice = create(:application_choice, status: 'recruited')

      post "/api/v1/applications/#{application_choice.id}/confirm-enrolment"

      expect(response).to have_http_status(200)
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq 'enrolled'
    end
  end

  it 'returns not found error when the application was not found' do
    post '/api/v1/applications/non-existent-id/confirm-enrolment'

    expect(response).to have_http_status(404)
    expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
    expect(error_response['message']).to eql('Could not find an application with ID non-existent-id')
  end
end
