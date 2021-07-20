require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1/applications/:application_id/offer', type: :request do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  around do |ex|
    Timecop.freeze { ex.run }
  end

  it_behaves_like 'an endpoint that requires metadata', '/offer'

  describe 'making an offer with specified conditions' do
    it 'returns the updated application' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
      request_body = {
        data: {
          conditions: [
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
        'offer_made_at' => Time.zone.now.iso8601(3),
        'offer_accepted_at' => nil,
        'offer_declined_at' => nil,
      )
    end

    it 'logs the request as a VendorAPIRequest', sidekiq: true do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
      request_body = {
        data: {
          conditions: [
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test',
          ],
        },
      }

      post_path = "/api/v1/applications/#{application_choice.id}/offer"

      expect {
        post_api_request post_path, params: request_body
      }.to change(VendorAPIRequest, :count)

      expect(VendorAPIRequest.first.request_path).to eq(post_path)
    end
  end

  describe 'making an offer with conditions with non UTF-8 characters' do
    it 'returns the updated application' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )
      request_body = {
        data: {
          conditions: [
            'Completion of subject knowledge enhancement°',
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
          'Completion of subject knowledge enhancement°',
          'Completion of professional skills test',
        ],
        'course' => course_option_to_course_payload(course_option),
        'offer_made_at' => Time.zone.now.iso8601(3),
        'offer_accepted_at' => nil,
        'offer_declined_at' => nil,
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
        'offer_made_at' => Time.zone.now.iso8601(3),
        'offer_accepted_at' => nil,
        'offer_declined_at' => nil,
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
      expect(error_response['message']).to match 'The specified course is not associated with any of your organisations.'
    end

    it 'logs the actual error in a VendorAPIRequest when a 422 is returned', sidekiq: true do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      other_course_option = course_option_for_provider(provider: create(:provider))

      expect {
        post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {
          'data' => {
            'conditions' => [],
            'course' => course_option_to_course_payload(other_course_option),
          },
        }
      }.to change(VendorAPIRequest, :count)

      expect(response).to have_http_status(422)

      logged_error = VendorAPIRequest.first.response_body['errors'].first['error']

      expect(logged_error).to eq('NotAuthorisedError')
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

    it 'returns an error when trying to transition to an invalid state' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'withdrawn',
      )

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: { data: { conditions: [] } }

      expect(response).to have_http_status(422)
      expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
      expect(error_response['message']).to eq 'The application is not ready for that action'
    end

    it 'returns a not found error if the application cannot be found' do
      request_body = {
        data: {
          conditions: [
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

    it 'does not process the conditions if they are not provided correctly' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      other_course_option = course_option_for_provider(provider: currently_authenticated_provider)

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {
        data: {
          conditions: 'INVALID CONDITION FORMAT',
          'course' => course_option_to_course_payload(other_course_option).except(:start_date),
        },
      }

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [],
        'course' => course_option_to_course_payload(other_course_option),
        'offer_made_at' => Time.zone.now.iso8601(3),
        'offer_accepted_at' => nil,
        'offer_declined_at' => nil,
      )
    end

    it 'does not require the course start date to be specified' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      other_course_option = course_option_for_provider(provider: currently_authenticated_provider)

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: {
        'data' => {
          'conditions' => [],
          'course' => course_option_to_course_payload(other_course_option).except(:start_date),
        },
      }

      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [],
        'course' => course_option_to_course_payload(other_course_option),
        'offer_made_at' => Time.zone.now.iso8601(3),
        'offer_accepted_at' => nil,
        'offer_declined_at' => nil,
      )
    end
  end

  describe 'offering for application with a decision' do
    it 'allows amending of course_option and conditions for existing offers' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'awaiting_provider_decision',
      )

      request_body = {
        data: {
          conditions: [
            'DBS Check',
          ],
        },
      }

      post_api_request "/api/v1/applications/#{application_choice.id}/offer", params: request_body
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')

      new_course_option = course_option_for_provider(provider: currently_authenticated_provider)

      request_body = {
        data: {
          conditions: [
            'DBS Check',
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test',
          ],
          course: course_option_to_course_payload(new_course_option),
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
        'offer_made_at' => Time.zone.now.iso8601(3),
        'offer_accepted_at' => nil,
        'offer_declined_at' => nil,
      )
    end

    it 'can change a rejection into an offer' do
      application_choice = create_application_choice_for_currently_authenticated_provider(
        status: 'rejected',
      )

      request_body = { data: { conditions: ['DBS Check'] } }
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
        data: {
          conditions: [],
        },
      }

      course_option = application_choice.course_option
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq('offer')
      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [],
        'course' => course_option_to_course_payload(course_option),
        'offer_made_at' => Time.zone.now.iso8601(3),
        'offer_accepted_at' => nil,
        'offer_declined_at' => nil,
      )
    end
  end

  describe 'changing offers' do
    it 'can change the offer conditions' do
      choice = create(:application_choice,
                      :with_completed_application_form,
                      :with_offer,
                      course_option: course_option_for_provider(provider: currently_authenticated_provider))

      request_body = {
        data: {
          conditions: [
            'Change your sheets',
            'Wash your clothes',
          ],
        },
      }

      post_api_request "/api/v1/applications/#{choice.id}/offer", params: request_body

      expect(parsed_response['data']['attributes']['offer']).to eq(
        'conditions' => [
          'Change your sheets',
          'Wash your clothes',
        ],
        'course' => course_option_to_course_payload(choice.course_option),
        'offer_made_at' => Time.zone.now.iso8601(3),
        'offer_accepted_at' => nil,
        'offer_declined_at' => nil,
      )
      expect(choice.offer.reload.conditions_text).to eq(['Change your sheets', 'Wash your clothes'])
    end

    it 'returns 200 OK when sending the same offer & conditions repeatedly' do
      choice = create(:application_choice,
                      :with_completed_application_form,
                      :with_offer,
                      course_option: course_option_for_provider(provider: currently_authenticated_provider))

      request_body = {
        data: {
          conditions: choice.offer.conditions_text,
          course: course_option_to_course_payload(choice.course_option),
        },
      }

      expect {
        post_api_request "/api/v1/applications/#{choice.id}/offer", params: request_body
      }.not_to(change { choice.reload })

      expect(response).to have_http_status(200)
    end
  end

  def course_option_to_course_payload(course_option)
    {
      'recruitment_cycle_year' => course_option.course.recruitment_cycle_year,
      'provider_code' => course_option.course.provider.code,
      'course_code' => course_option.course.code,
      'site_code' => course_option.site.code,
      'study_mode' => course_option.study_mode,
      'start_date' => course_option.course.start_date.strftime('%Y-%m'),
    }
  end
end
