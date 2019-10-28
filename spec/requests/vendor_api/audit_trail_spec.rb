require 'rails_helper'

RSpec.describe 'Vendor API - audit trail', type: :request do
  include VendorApiSpecHelpers
  include CourseOptionHelpers

  it 'updates the audit trail with the correct attribution when successfully rejecting an application' do
    application_choice = create_application_choice_for_currently_authenticated_provider(status: 'application_complete')
    request_body = {
      "data": {
        "reason": 'Does not meet minimum GCSE requirements',
      },
    }

    expect {
      post_api_request "/api/v1/applications/#{application_choice.id}/reject", params: request_body
    }.to(change { application_choice.audits.count })
    expect(application_choice.audits.last.user).to be_present
    expect(application_choice.audits.last.user.full_name).to eq(
      VendorApiSpecHelpers::VALID_METADATA[:attribution][:full_name],
    )
    expect(application_choice.audits.last.user.email_address).to eq(
      VendorApiSpecHelpers::VALID_METADATA[:attribution][:email],
    )
    expect(application_choice.audits.last.user.vendor_user_id).to eq(
      VendorApiSpecHelpers::VALID_METADATA[:attribution][:user_id],
    )
  end

  it 'updates the audit trail but reuses a VendorApiUser with same vendor_user_id when rejecting an application' do
    application_choice = create_application_choice_for_currently_authenticated_provider(status: 'application_complete')
    unhashed_token = VendorApiToken.create_with_random_token!(provider: currently_authenticated_provider)
    create(
      :vendor_api_user,
      full_name: VendorApiSpecHelpers::VALID_METADATA[:attribution][:full_name],
      email_address: 'jane.smith@example.com',
      vendor_user_id: VendorApiSpecHelpers::VALID_METADATA[:attribution][:user_id],
      vendor_api_token_id: VendorApiToken.find_by_unhashed_token(unhashed_token).id,
    )
    request_body = {
      "data": {
        "reason": 'Does not meet minimum GCSE requirements',
      },
    }

    expect {
      post_api_request(
        "/api/v1/applications/#{application_choice.id}/reject",
        params: request_body,
        headers: {
          'Authorization' => "Bearer #{unhashed_token}",
          'Content-Type' => 'application/json',
        },
      )
    }.to(change { VendorApiUser.count }.by(0))
    expect(application_choice.audits.last.user.email_address).to eq 'jane@example.com'
  end
end
