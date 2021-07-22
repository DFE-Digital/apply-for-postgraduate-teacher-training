require 'rails_helper'

RSpec.feature 'Setting up organisation permissions' do
  include DfESignInHelpers

  before { FeatureFlag.activate(:accredited_provider_setting_permissions) }

  scenario 'Provider user sets up organisation permissions' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_manage_organisations
    and_my_organisations_have_not_had_permissions_setup

    when_i_sign_in_to_the_provider_interface
    then_i_can_see_the_organisations_needing_permissions_setup

    when_i_click_set_up_organisation_permissions
    then_i_see_the_first_relationship

    when_i_select_a_provider_for_each_permission
    and_i_click_on_continue
    then_i_see_the_next_relationship

    when_i_do_not_complete_the_permissions_details
    and_i_click_on_continue
    then_i_see_the_error_message

    when_i_complete_the_permissions_details
    and_i_click_on_continue
    then_i_see_the_check_relationship_permissions_page

    when_i_click_on_change
    and_i_change_the_provider_permission
    and_i_click_on_continue
    then_i_see_the_check_relationship_permissions_page
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
  end

  def and_i_can_manage_organisations
    @provider_user = ProviderUser.last
    @training_provider = Provider.find_by(code: 'ABC')
    @ratifying_provider = Provider.find_by(code: 'DEF')

    @another_ratifying_provider = create(:provider, :with_signed_agreement)
    @another_training_provider = create(:provider, :with_signed_agreement)
    @provider_user.provider_permissions.update_all(manage_organisations: true)
  end

  def and_my_organisations_have_not_had_permissions_setup
    create(
      :provider_relationship_permissions,
      ratifying_provider: @another_ratifying_provider,
      training_provider: @training_provider,
      training_provider_can_make_decisions: false,
      training_provider_can_view_safeguarding_information: false,
      training_provider_can_view_diversity_information: false,
      setup_at: nil,
    )
    create(:course, :open_on_apply, provider: @training_provider, accredited_provider: @another_ratifying_provider)

    create(
      :provider_relationship_permissions,
      ratifying_provider: @ratifying_provider,
      training_provider: @another_training_provider,
      training_provider_can_make_decisions: false,
      training_provider_can_view_safeguarding_information: false,
      training_provider_can_view_diversity_information: false,
      setup_at: nil,
    )
    create(:course, :open_on_apply, provider: @another_training_provider, accredited_provider: @ratifying_provider)
  end

  alias_method :when_i_sign_in_to_the_provider_interface, :and_i_sign_in_to_the_provider_interface

  def then_i_can_see_the_organisations_needing_permissions_setup
    expect(page).to have_content('Set up organisation permissions')
    expect(page).to have_content('Candidates can now apply through GOV.UK for courses you work on with partner organisations')
    expect(page).to have_content("For #{@training_provider.name}, you need to set up permissions for courses you work on with:")
    expect(page).to have_content(@another_ratifying_provider.name)
    expect(page).to have_content("For #{@ratifying_provider.name}, you need to set up permissions for courses you work on with:")
    expect(page).to have_content(@another_training_provider.name)
  end

  def when_i_click_set_up_organisation_permissions
    click_on 'Set up organisation permissions'
  end

  def then_i_see_the_first_relationship
    expect(page).to have_content("#{@ratifying_provider.name} and #{@another_training_provider.name}")
  end

  def when_i_select_a_provider_for_each_permission
    within('[data-qa="make-decisions"]') { check @ratifying_provider.name }
    within('[data-qa="view-safeguarding-information"]') { check @ratifying_provider.name }
    within('[data-qa="view-safeguarding-information"]') { check @another_training_provider.name }
    within('[data-qa="view-diversity-information"]') { check @ratifying_provider.name }
  end

  def and_i_click_on_continue
    click_on 'Continue'
  end

  def then_i_see_the_next_relationship
    expect(page).to have_content("#{@training_provider.name} and #{@another_ratifying_provider.name}")
  end

  def when_i_do_not_complete_the_permissions_details
    within('[data-qa="view-safeguarding-information"]') { check @training_provider.name }
    within('[data-qa="view-diversity-information"]') { check @another_ratifying_provider.name }
  end

  def then_i_see_the_error_message
    expect(page).to have_content('Select which organisations can make decisions')
  end

  def when_i_complete_the_permissions_details
    within('[data-qa="make-decisions"]') { check @another_ratifying_provider.name }
  end

  def then_i_see_the_check_relationship_permissions_page
    expect(page).to have_content('Check and save organisation permissions')
  end

  def when_i_click_on_change
    click_on 'Change', match: :first
  end

  def and_i_change_the_provider_permission
    within('[data-qa="make-decisions"]') { check @another_training_provider.name }
    within('[data-qa="view-safeguarding-information"]') { check @another_training_provider.name }
    within('[data-qa="view-diversity-information"]') { check @another_training_provider.name }
  end
end
