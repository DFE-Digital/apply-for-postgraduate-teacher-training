require 'rails_helper'

RSpec.feature 'Add course to submitted application' do
  include DfESignInHelpers

  scenario 'Support user adds course to submitted application' do
    given_i_am_a_support_user
    and_there_is_an_offered_application_in_the_system
    and_i_visit_the_support_page

    when_i_click_on_the_application
    then_i_should_see_the_current_conditions

    when_i_click_on_change_conditions
    then_i_see_the_condition_edit_form_with_a_warning

    when_i_add_a_new_condition_and_click_update_conditions
    then_i_see_the_new_condition_as_well_as_the_original_ones
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_offered_application_in_the_system
    candidate = create :candidate, email_address: 'candy@example.com'

    Audited.audit_class.as_user(candidate) do
      @application_form = create(
        :completed_application_form,
        first_name: 'Candy',
        last_name: 'Dayte',
        candidate: candidate,
      )

      @application_choice = create(
        :application_choice,
        :with_accepted_offer,
        application_form: @application_form,
      )
    end
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_the_application
    click_on 'Candy Dayte'
  end

  def then_i_should_see_the_current_conditions
    expect(page).to have_content("Conditions\nBe cool")
  end

  def when_i_click_on_change_conditions
    click_on 'Change conditions'
  end

  def then_i_see_the_condition_edit_form_with_a_warning
    expect(page).to have_current_path(
      support_interface_update_application_choice_conditions_path(@application_choice)
    )
  end

  def when_i_add_a_new_condition_and_click_update_conditions
    check 'Fitness to train to teach check'
    fill_in 'Condition 2', with: 'Learn to play piano'
    click_on 'Continue'
  end

  def then_i_see_the_new_condition_as_well_as_the_original_ones
    expect(page).to have_content(
      "Conditions\nFitness to train to teach check Be cool Learn to play piano",
    )
  end
end