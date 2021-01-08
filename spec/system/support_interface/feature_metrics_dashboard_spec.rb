require 'rails_helper'

RSpec.feature 'Feature metrics dashboard' do
  include DfESignInHelpers

  around do |example|
    @today = Time.zone.local(2020, 12, 24, 12)
    Timecop.freeze(@today) do
      example.run
    end
  end

  scenario 'View feature metrics', with_audited: true do
    given_i_am_a_support_user
    and_there_are_candidates_and_application_forms_in_the_system

    when_i_visit_the_performance_page_in_support
    and_i_click_on_the_feature_metrics_link

    then_i_should_see_reference_metrics
    and_i_should_see_work_history_metrics
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def create_application_form_with_references
    application_form = create(:application_form)
    references = create_list(:reference, 2, application_form: application_form)
    references.each { |reference| CandidateInterface::RequestReference.new.call(reference) }
    [application_form, references]
  end

  def provide_references(references)
    references.each { |reference| SubmitReference.new(reference: reference, send_emails: false).save! }
  end

  def start_work_history(application_form)
    create(:application_work_experience, application_form: application_form)
  end

  def complete_work_history(application_form)
    application_form.update!(work_history_completed: true)
  end

  def and_there_are_candidates_and_application_forms_in_the_system
    allow(EndOfCycleTimetable).to receive(:apply_reopens).and_return(60.days.ago)
    Timecop.freeze(@today - 50.days) do
      @application_form1, @references1 = create_application_form_with_references
      @application_form2, @references2 = create_application_form_with_references
      start_work_history(@application_form1)
    end
    Timecop.freeze(@today - 40.days) do
      @application_form3, @references3 = create_application_form_with_references
      provide_references(@references1)
      start_work_history(@application_form2)
      complete_work_history(@application_form1)
    end
    Timecop.freeze(@today - 21.days) do
      @application_form4, @references4 = create_application_form_with_references
      provide_references(@references2)
      complete_work_history(@application_form2)
      start_work_history(@application_form3)
      start_work_history(@application_form4)
    end
    Timecop.freeze(@today - 2.days) do
      provide_references(@references3)
      provide_references(@references4)
      complete_work_history(@application_form3)
      complete_work_history(@application_form4)
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
    within('#references_dashboard_section') do
      expect(page).to have_content('24 days average time to get reference back')
      expect(page).to have_content('10 days last month')
      expect(page).to have_content('28.7 days this month')
      expect(page).to have_content('75% completed within 30 days')
      expect(page).to have_content('100% last month')
      expect(page).to have_content('66.7% this month')
    end
  end

  def and_i_should_see_work_history_metrics
    within('#work_history_dashboard_section') do
      expect(page).to have_content('16.8 this cycle')
      expect(page).to have_content('19 last month')
    end
  end
end
