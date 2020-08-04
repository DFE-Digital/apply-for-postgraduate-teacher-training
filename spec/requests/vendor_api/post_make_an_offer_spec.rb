require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1/applications/:application_id/offer', type: :request do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  it_behaves_like 'an endpoint that requires metadata', '/offer'

  describe 'making an offer with specified conditions' do
    it 'returns the updated application' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
      request_body = {
        "data": {
          "conditions": [
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test',
          ],
        },
      }
      expect(request_body[:data]).to be_valid_against_openapi_schema('MakeOffer')

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: request_body

      course_option = application_choice.course_option
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq('offer')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [
          'Completion of subject knowledge enhancement',
          'Completion of professional skills test',
        ],
        'course' => course_option_to_course_payload(course_option),
      )
    end
  end

  describe 'making an offer for another course' do
    it 'returns the updated application' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      other_course_option = course_option_for_provider(provider: currently_authenticated_provider)

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {
        'data' => {
          'conditions' => [],
          'course' => course_option_to_course_payload(other_course_option),
        },
      }

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [],
        'course' => course_option_to_course_payload(other_course_option),
      )
    end

    it 'returns an error when specifying a course from a different provider' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      other_course_option = course_option_for_provider(provider: create(:provider))

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {
        'data' => {
          'conditions' => [],
          'course' => course_option_to_course_payload(other_course_option),
        },
      }

      expect(response).to have_http_status(422)
      expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
      expect(error_response['message']).to match 'You are not allowed to make decisions'
    end

    it 'returns an error when specifying a course that is not open on Apply' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      course = create(:course, provider: currently_authenticated_provider)
      other_course_option = course_option_for_provider(provider: currently_authenticated_provider, course: course)

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {
        'data' => {
          'conditions' => [],
          'course' => course_option_to_course_payload(other_course_option),
        },
      }

      expect(response).to have_http_status(422)
      expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
      expect(error_response['message']).to match 'The requested course is not open for applications via the Apply service'
    end

    it 'returns an error when making an offer on the same course twice' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {
        'data' => {
          'conditions' => [],
        },
      }

      expect(response).to have_http_status(200)

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {
        'data' => {
          'conditions' => [],
        },
      }

      expect(response).to have_http_status(422)
      expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
      expect(error_response['message']).to match 'The new course is the same as the course currently offered'
    end

    it 'returns an error when specifying a course that does not exist' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {
        'data' => {
          'conditions' => [],
          'course' => {
            'recruitment_cycle_year' => 2030,
            'provider_code' => 'ABC',
            'course_code' => 'X100',
            'site_code' => 'E',
            'study_mode' => 'full_time',
          },
        },
      }

      expect(response).to have_http_status(422)
      expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
      expect(error_response['message']).to match 'The requested course could not be found'
    end
  end

  describe 'offering for application with a decision' do
    it 'allows amending of course_option and conditions for existing offers' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      request_body = {
        "data": {
          "conditions": [
            'DBS Check',
          ],
        },
      }

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: request_body
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')

      new_course_option = course_option_for_provider(provider: currently_authenticated_provider)

      request_body = {
        "data": {
          "conditions": [
            'DBS Check',
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test',
          ],
          "course": course_option_to_course_payload(new_course_option),
        },
      }

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: request_body

      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [
          'DBS Check',
          'Completion of subject knowledge enhancement',
          'Completion of professional skills test',
        ],
        'course' => course_option_to_course_payload(new_course_option),
      )
    end

    it 'can change a rejection into an offer' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'rejected',
      )

      request_body = { "data": { "conditions": ['DBS Check'] } }
      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: request_body

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq('offer')
    end
  end

  describe 'making an offer without specified conditions' do
    it 'returns the updated application' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {
        "data": {
          "conditions": [],
        },
      }

      course_option = application_choice.course_option
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq('offer')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [],
        'course' => course_option_to_course_payload(course_option),
      )
    end
  end

  it 'returns an error when trying to transition to an invalid state' do
    application_choice = create_application_choice_for_currently_authenticated_provider(
      status: 'withdrawn',
    )

    post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {}

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
    expect(error_response['message']).to eq 'The application is not ready for that action'
  end

  it 'returns an error when given invalid conditions' do
    application_choice = create_application_choice_for_currently_authenticated_provider(
      status: 'awaiting_provider_decision',
    )

    post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {
      data: {
        conditions: 'DO NOT WANT',
      },
    }

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
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

    post_api_request '/api/v1/applications/non-existent-id/offer', params: request_body

    expect(response).to have_http_status(404)
    expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
    expect(error_response['message']).to eql('Could not find an application with ID non-existent-id')
  end

  def course_option_to_course_payload(course_option)
    {
      'recruitment_cycle_year' => course_option.course.recruitment_cycle_year,
      'provider_code' => course_option.course.provider.code,
      'course_code' => course_option.course.code,
      'site_code' => course_option.site.code,
      'study_mode' => course_option.study_mode,
    }
  end
end
