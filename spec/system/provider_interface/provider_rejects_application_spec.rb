require 'rails_helper'

RSpec.feature 'Provider rejects application' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }
  let(:application_awaiting_provider_decision) do
    create(:application_choice, status: 'awaiting_provider_decision', course_option: course_option, application_form: create(:completed_application_form, first_name: 'Alice', last_name: 'Wunder'))
  end

  scenario 'Provider rejects application' do
    FeatureFlag.deactivate(:structured_reasons_for_rejection)

    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_respond_to_a_submitted_application
    and_i_choose_to_reject_it
    and_i_add_a_rejection_reason
    and_i_click_to_continue
    then_i_am_asked_to_confirm_the_rejection

    rejecting_an_application_is_tracked_as_a_decision { when_i_confirm_the_rejection }
    then_i_am_back_to_the_application_page
    and_i_can_see_the_application_has_just_been_rejected
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    @provider_user = provider_user_exists_in_apply_database
  end

  def and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    permit_make_decisions!
  end

  def when_i_respond_to_a_submitted_application
    visit provider_interface_application_choice_respond_path(
      application_awaiting_provider_decision.id,
    )
  end

  def and_i_choose_to_reject_it
    choose 'Reject application'
    click_on 'Continue'
  end

  def and_i_add_a_rejection_reason
    fill_in('Feedback for candidate', with: 'A rejection reason')
  end

  def and_i_click_to_continue
    click_on 'Continue'
  end

  def then_i_am_asked_to_confirm_the_rejection
    expect(page).to have_current_path(
      provider_interface_application_choice_confirm_reject_path(
        application_awaiting_provider_decision.id,
      ),
    )
  end

  def when_i_confirm_the_rejection
    click_on 'Reject application'
  end

  def rejecting_an_application_is_tracked_as_a_decision(&block)
    expect {
      yield(block)
    }.to have_metrics_tracked_with_interval(application_awaiting_provider_decision, 'notifications.update.on', @provider_user, anything, :decision)
  end

  def then_i_am_back_to_the_application_page
    expect(page).to have_current_path(
      provider_interface_application_choice_path(
        application_awaiting_provider_decision.id,
      ),
    )
  end

  def and_i_can_see_the_application_has_just_been_rejected
    expect(page).to have_content 'Application successfully rejected'
  end
end
