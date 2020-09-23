require 'rails_helper'
require 'services/duplicate_application_shared_examples'

RSpec.describe ApplyAgain do
  def original_application_form
    Timecop.travel(-1.day) do
      @original_application_form ||= create(
        :completed_application_form,
        application_choices_count: 3,
        work_experiences_count: 1,
        volunteering_experiences_count: 1,
        with_gcses: true,
        full_work_history: true,
        recruitment_cycle_year: RecruitmentCycle.current_year,
      )
      create_list(:reference, 2, feedback_status: :feedback_provided, application_form: @original_application_form)
      create(:reference, feedback_status: :feedback_refused, application_form: @original_application_form)
    end
    @original_application_form
  end

  it_behaves_like 'duplicates application form', 'apply_2', RecruitmentCycle.current_year
end
