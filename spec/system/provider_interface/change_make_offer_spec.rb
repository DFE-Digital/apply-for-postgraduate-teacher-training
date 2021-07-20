require 'rails_helper'

RSpec.feature 'Provider makes an offer' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in) }
  let(:provider) { provider_user.providers.first }
  let(:ratifying_provider) { create(:provider) }
  let(:application_form) { build(:application_form, :minimum_info) }
  let!(:application_choice) do
    create(:application_choice, :awaiting_provider_decision,
           application_form: application_form,
           course_option: course_option)
  end
  let(:course) do
    build(:course, :open_on_apply, :full_time, provider: provider, accredited_provider: ratifying_provider)
  end
  let(:course_option) { build(:course_option, course: course) }

  scenario 'Making an offer for the requested course option' do
    given_i_am_a_provider_user
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_i_sign_in_to_the_provider_interface

    given_the_provider_user_can_offer_multiple_provider_courses

    when_i_visit_the_provider_interface
    and_i_click_an_application_choice_awaiting_decision
    and_i_click_on_make_decision
    then_i_see_the_decision_page

    when_i_choose_to_change_and_make_an_offer
    then_i_am_taken_to_the_change_provider_page

    when_i_select_a_different_provider
    and_i_click_continue

    when_i_select_a_different_course
    and_i_click_continue
    then_no_study_mode_is_pre_selected

    when_i_select_a_study_mode
    and_i_click_continue

    when_i_select_a_new_location
    and_i_click_continue

    then_the_conditions_page_is_loaded
    and_i_click_continue

    then_the_review_page_is_loaded
    and_i_can_confirm_the_changed_offer_details

    when_i_send_the_offer
    then_i_see_that_the_offer_was_successfuly_made
  end

  def given_i_am_a_provider_user
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
  end

  def and_i_am_permitted_to_make_decisions_for_my_provider
    permit_make_decisions!
  end

  def and_i_sign_in_to_the_provider_interface
    provider_signs_in_using_dfe_sign_in
  end

  def when_i_visit_the_provider_interface
    visit provider_interface_applications_path
  end

  def and_i_click_an_application_choice_awaiting_decision
    click_on application_choice.application_form.full_name
  end

  def and_i_click_on_make_decision
    click_on 'Make decision'
  end

  def then_i_see_the_decision_page
    expect(page).to have_content('Make a decision')
    expect(page).to have_content('Course applied for')
  end

  def when_i_choose_to_change_and_make_an_offer
    choose 'Change course details and make an offer'
    and_i_click_continue
  end

  def then_the_conditions_page_is_loaded
    expect(page).to have_content('Conditions of offer')
  end

  def and_the_default_conditions_are_checked
    expect(find("input[value='Fitness to train to teach check']")).to be_checked
    expect(find("input[value='Disclosure and Barring Service (DBS) check']")).to be_checked
  end

  def when_i_add_further_conditions
    fill_in('provider_interface_offer_wizard[further_conditions][0][text]', with: 'A* on Maths A Level')
  end

  def and_i_click_continue
    click_on t('continue')
  end

  def then_the_review_page_is_loaded
    expect(page).to have_content('Check and send offer')
  end

  def and_i_can_confirm_my_answers
    within('.app-offer-panel') do
      expect(page).to have_content('A* on Maths A Level')
    end
  end

  def then_i_am_taken_to_the_change_location_page
    expect(page).to have_content('Select location')
  end

  def when_i_select_a_new_location
    choose @selected_course_option.site_name
  end

  def then_i_am_taken_to_the_change_study_mode_page
    expect(page).to have_content('Select study mode')
  end

  def when_i_select_a_study_mode
    choose @selected_course_option.study_mode.humanize
  end

  def when_i_select_a_different_course
    choose @selected_course.name_and_code
  end

  def then_no_study_mode_is_pre_selected
    expect(find_field('Full time')).not_to be_checked
    expect(find_field('Part time')).not_to be_checked
  end

  def then_i_am_taken_to_the_change_course_page
    expect(page).to have_content('Select course')
  end

  def given_the_provider_user_can_offer_multiple_provider_courses
    @selected_provider = create(:provider, :with_signed_agreement)
    create(:provider_permissions, provider: @selected_provider, provider_user: provider_user, make_decisions: true)
    courses = [create(:course, :open_on_apply, study_mode: :full_time_or_part_time, provider: @selected_provider, accredited_provider: ratifying_provider),
               create(:course, :open_on_apply, study_mode: :full_time_or_part_time, provider: @selected_provider, accredited_provider: ratifying_provider)]
    @selected_course, other_course = courses.sample(2)

    course_options = [create(:course_option, :part_time, course: @selected_course),
                      create(:course_option, :full_time, course: @selected_course),
                      create(:course_option, :full_time, course: @selected_course),
                      create(:course_option, :part_time, course: @selected_course)]
    create(:course_option, :part_time, course: other_course)

    create(
      :provider_relationship_permissions,
      training_provider: provider,
      ratifying_provider: ratifying_provider,
      ratifying_provider_can_make_decisions: true,
    )

    create(
      :provider_relationship_permissions,
      training_provider: @selected_provider,
      ratifying_provider: ratifying_provider,
      ratifying_provider_can_make_decisions: true,
    )

    @selected_course_option = course_options.sample
  end

  def then_i_am_taken_to_the_change_provider_page
    expect(page).to have_content('Select training provider')
  end

  def when_i_select_a_different_provider
    choose @selected_provider.name_and_code
  end

  def and_i_can_confirm_the_changed_offer_details
    within('.app-summary-card__body') do
      expect(page).to have_content(@selected_provider.name_and_code)
      expect(page).to have_content(@selected_course.name_and_code)
      expect(page).to have_content(@selected_course_option.study_mode.humanize)
      expect(page).to have_content(@selected_course_option.site.name_and_address)
    end
  end

  def when_i_send_the_offer
    click_on 'Send offer'
  end

  def then_i_see_that_the_offer_was_successfuly_made
    within('.govuk-notification-banner--success') do
      expect(page).to have_content('Offer sent')
    end
  end
end
