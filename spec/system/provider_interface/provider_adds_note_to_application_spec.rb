require 'rails_helper'

RSpec.describe 'A Provider viewing an individual application', with_audited: true do
  include CourseOptionHelpers
  include DfESignInHelpers

  around do |example|
    Timecop.freeze(Time.zone.local(2020, 3, 1, 12, 0, 0)) do
      example.run
    end
  end

  scenario 'adds a note' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_the_notes_feature_flag_is_active
    and_the_timeline_feature_flag_is_active
    and_my_organisation_has_received_an_application
    and_i_sign_in_to_the_provider_interface

    when_i_visit_that_application_in_the_provider_interface
    and_i_visit_the_notes_tab
    and_i_click_to_add_a_note
    and_i_write_a_note_with_a_title_and_a_message

    then_i_am_still_on_the_notes_tab
    and_the_notes_tab_includes_the_new_note
    and_the_new_note_also_appears_on_the_timeline
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    @provider = create(:provider, :with_signed_agreement)
    provider_user = create(:provider_user, dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    provider_user.providers << @provider
    user_exists_in_dfe_sign_in
  end

  def and_the_notes_feature_flag_is_active
    FeatureFlag.activate('notes')
  end

  def and_the_timeline_feature_flag_is_active
    FeatureFlag.activate('timeline')
  end

  def and_my_organisation_has_received_an_application
    course_option = course_option_for_provider_code(provider_code: @provider.code)
    @application_choice = create(:application_choice, :awaiting_provider_decision, course_option: course_option)
  end

  def when_i_visit_that_application_in_the_provider_interface
    visit provider_interface_application_choice_path(@application_choice)
  end

  def and_i_visit_the_notes_tab
    click_on 'Notes'
  end

  def and_i_click_to_add_a_note
    click_on 'Add note'
  end

  def and_i_write_a_note_with_a_title_and_a_message
    @note_title = 'Documents missing'
    @note_message = 'The candidate has not forwarded the required documents yet.'
    fill_in 'Title', with: @note_title
    fill_in 'Message', with: @note_message
    click_on 'Save note'
  end

  def then_i_am_still_on_the_notes_tab
    expect(page).to have_current_path(provider_interface_application_choice_notes_path(@application_choice))
  end

  def and_the_notes_tab_includes_the_new_note
    expect(page).to have_content(@note_title)
    expect(page).to have_content(@note_message)
  end

  def and_the_new_note_also_appears_on_the_timeline
    click_on 'Timeline'
    expect(page).to have_content(@note_title)
  end
end
