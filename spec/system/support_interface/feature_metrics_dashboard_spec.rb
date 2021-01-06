require 'rails_helper'

RSpec.feature 'Feature metrics dashboard' do
  include DfESignInHelpers

  scenario 'View feature metrics', with_audited: true do
    given_i_am_a_support_user
    and_there_are_candidates_and_application_forms_in_the_system

    when_i_visit_the_performance_page_in_support
    and_i_click_on_the_feature_metrics_link

    then_i_should_see_reference_metrics
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_and_application_forms_in_the_system
    Timecop.freeze(Time.zone.now - 12.days) do
      @application_form1 = create(:application_form)
      @references1 = create_list(:reference, 2, application_form: @application_form1)
      @references1.each { |reference| CandidateInterface::RequestReference.new.call(reference) }

      @application_form2 = create(:application_form)
      @references2 = create_list(:reference, 2, application_form: @application_form2)
      @references2.each { |reference| CandidateInterface::RequestReference.new.call(reference) }
    end
    Timecop.freeze(Time.zone.now - 9.days) do
      @references1.each { |reference| SubmitReference.new(reference: reference, send_emails: false).save! }
    end
    Timecop.freeze(Time.zone.now) do
      @references2.each { |reference| SubmitReference.new(reference: reference, send_emails: false).save! }
    end
  end

  def when_i_visit_the_performance_page_in_support
    visit support_interface_performance_path
  end

  def and_i_click_on_the_feature_metrics_link
    click_on 'Feature metrics'
  end

  def then_i_should_see_reference_metrics
    expect(page).to have_content('Feature metrics')
    expect(page).to have_content('12 today')
    expect(page).to have_content('7.5 last month')
  end
end
