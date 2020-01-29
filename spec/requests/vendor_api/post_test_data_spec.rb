require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1/test-data', type: :request do
  include VendorApiSpecHelpers
  include CourseOptionHelpers

  describe '/regenerate' do
    it 'generates test data' do
      post_api_request '/api/v1/test-data/regenerate?count=3'

      expect(Candidate.count).to be(3)
      expect(parsed_response).to be_valid_against_openapi_schema('OkResponse')
    end

    it 'generates test data with default count of 100' do
      generate_test_data = instance_double(GenerateTestData, generate: nil)
      allow(GenerateTestData).to receive(:new).and_return(generate_test_data)
      post_api_request '/api/v1/test-data/regenerate'

      expect(GenerateTestData).to have_received(:new).with(100, anything)
      expect(parsed_response).to be_valid_against_openapi_schema('OkResponse')
    end

    it 'does not generate test data in production' do
      ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'production' do
        post_api_request '/api/v1/test-data/regenerate?count=3'
      end

      expect(Candidate.count).to be(0)
      expect(response.code).to eql '400'
      expect(parsed_response).to be_valid_against_openapi_schema('OkResponse')
    end
  end

  describe '/generate' do
    before do
      FeatureFlag.activate('new_test_data_endpoints')
    end

    it 'generates test data' do
      create(:course_option, course: create(:course, open_on_apply: true, provider: currently_authenticated_provider))

      post_api_request '/api/v1/test-data/generate?count=1'

      expect(Candidate.count).to eq(1)
      expect(ApplicationChoice.count).to eq(1)
      expect(parsed_response).to be_valid_against_openapi_schema('TestDataGeneratedResponse')
    end

    it 'respects the courses_per_application= parameter' do
      create(:course_option, course: create(:course, open_on_apply: true, provider: currently_authenticated_provider))
      create(:course_option, course: create(:course, open_on_apply: true, provider: currently_authenticated_provider))

      post_api_request '/api/v1/test-data/generate?count=1&courses_per_application=2'

      expect(Candidate.count).to eq(1)
      expect(ApplicationChoice.count).to eq(2)
      expect(ApplicationChoice.all.map(&:status).uniq).to eq(['awaiting_provider_decision'])

      expect(parsed_response).to be_valid_against_openapi_schema('TestDataGeneratedResponse')
    end

    it 'does not generate more than three application_choices per application' do
      create(:course_option, course: create(:course, open_on_apply: true, provider: currently_authenticated_provider))
      create(:course_option, course: create(:course, open_on_apply: true, provider: currently_authenticated_provider))
      create(:course_option, course: create(:course, open_on_apply: true, provider: currently_authenticated_provider))

      post_api_request '/api/v1/test-data/generate?count=1&courses_per_application=99'

      expect(Candidate.count).to eq(1)
      expect(ApplicationChoice.count).to eq(3)
      expect(parsed_response).to be_valid_against_openapi_schema('TestDataGeneratedResponse')
    end
  end

  describe '/clear' do
    before do
      FeatureFlag.activate('new_test_data_endpoints')
    end

    it 'clears test data' do
      create(
        :application_choice,
        :awaiting_provider_decision,
        course_option: course_option_for_provider(provider: currently_authenticated_provider),
      )

      expect {
        post_api_request('/api/v1/test-data/clear')
      }.to change {
        get_api_request('/api/v1/applications?since=1970-01-01')
        parsed_response['data'].count
      }.from(1).to(0)
    end

    it 'returns responses conforming to the schema' do
      post_api_request('/api/v1/test-data/clear')
      expect(parsed_response).to be_valid_against_openapi_schema('OkResponse')
    end
  end
end
