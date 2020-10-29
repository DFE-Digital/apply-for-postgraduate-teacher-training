require 'rails_helper'

RSpec.describe PerformanceStatistics, type: :model do
  describe '#[]' do
    it 'counts candidates without application forms' do
      create(:candidate)

      expect(ProcessState.new(nil).state).to be :never_signed_in

      expect(count_for_process_state(:never_signed_in)).to be(1)
    end

    it 'counts unsubmitted, unstarted applications' do
      application_choice = create(:application_choice, status: 'unsubmitted')
      form = application_choice.application_form
      form.update_column(:updated_at, form.created_at)

      expect(ProcessState.new(form).state).to be :unsubmitted_not_started_form

      expect(count_for_process_state(:unsubmitted_not_started_form)).to be(1)
    end

    it 'counts unsubmitted, unstarted applications from both phases' do
      application_choice = create(:application_choice, status: 'unsubmitted')
      form = application_choice.application_form
      form.update_column(:updated_at, form.created_at)

      apply_again_form = create(:application_form, phase: 'apply_2')
      create(:application_choice, status: 'unsubmitted', application_form: apply_again_form)
      apply_again_form.update_column(:updated_at, form.created_at)

      expect(ProcessState.new(form).state).to be :unsubmitted_not_started_form

      expect(count_for_process_state(:unsubmitted_not_started_form)).to be(2)
    end

    it 'counts unsubmitted, unstarted applications without choices' do
      form = create(:application_form)

      expect(ProcessState.new(form).state).to be :unsubmitted_not_started_form

      expect(count_for_process_state(:unsubmitted_not_started_form)).to be(1)
    end

    it 'counts unsubmitted, started applications' do
      application_choice = create(:application_choice, status: 'unsubmitted')
      application_choice.application_form.update_column(:updated_at, Time.zone.now + 1.day)

      expect(ProcessState.new(application_choice.application_form).state).to be :unsubmitted_in_progress

      expect(count_for_process_state(:unsubmitted_in_progress)).to be(1)
    end

    it 'counts applications awaiting a provider decision' do
      application_choice = create(:application_choice, status: 'awaiting_provider_decision')
      create(:application_choice, application_form: application_choice.application_form, status: 'offer')

      expect(ProcessState.new(application_choice.application_form).state).to be :awaiting_provider_decisions

      expect(count_for_process_state(:awaiting_provider_decisions)).to be(1)
    end

    it 'counts applications with offers' do
      form = create(:application_form)
      create_list(:application_choice, 2, application_form: form, status: 'offer')

      expect(ProcessState.new(form).state).to be :awaiting_candidate_response

      expect(count_for_process_state(:awaiting_candidate_response)).to be(1)
    end

    it 'counts recruited applications' do
      application_choice = create(:application_choice, status: 'recruited')

      expect(ProcessState.new(application_choice.application_form).state).to be :recruited

      expect(count_for_process_state(:recruited)).to be(1)
    end

    it 'counts applications pending conditions' do
      application_choice = create(:application_choice, status: 'pending_conditions')

      expect(ProcessState.new(application_choice.application_form).state).to be :pending_conditions

      expect(count_for_process_state(:pending_conditions)).to be(1)
    end

    it 'counts applications that ended without success' do
      withdrawn_form, rejected_form, declined_form, conditions_not_met_form = create_list(:application_form, 4)
      create_list(:application_choice, 2, application_form: withdrawn_form, status: 'withdrawn')
      create_list(:application_choice, 2, application_form: rejected_form, status: 'rejected')
      create_list(:application_choice, 2, application_form: declined_form, status: 'declined')
      create_list(:application_choice, 2, application_form: conditions_not_met_form, status: 'conditions_not_met')

      expect(ProcessState.new(withdrawn_form).state).to be :ended_without_success
      expect(ProcessState.new(rejected_form).state).to be :ended_without_success
      expect(ProcessState.new(declined_form).state).to be :ended_without_success
      expect(ProcessState.new(conditions_not_met_form).state).to be :ended_without_success

      expect(count_for_process_state(:ended_without_success)).to be(4)
    end
  end

  describe '#total_candidate_count' do
    it 'optionally filters only on certain process states and excludes certain states' do
      create(:application_choice, status: 'recruited')
      create(:application_choice, status: 'recruited')
      create(:application_choice, status: 'pending_conditions')

      stats = PerformanceStatistics.new(nil)

      expect(stats.total_candidate_count(only: %i[recruited])).to eq(2)
      expect(stats.total_candidate_count(except: %i[pending_conditions])).to eq(2)
    end

    it 'optionally filters by phase' do
      apply_1_form = create(:application_form, phase: 'apply_1')
      apply_2_form = create(:application_form, phase: 'apply_2')
      create(:application_choice, status: 'recruited', application_form: apply_1_form)
      create(:application_choice, status: 'recruited', application_form: apply_2_form)
      create(:application_choice, status: 'pending_conditions')

      stats = PerformanceStatistics.new(nil)

      expect(stats.total_candidate_count(only: %i[recruited])).to eq(2)
      expect(stats.total_candidate_count(only: %i[recruited], phase: :apply_1)).to eq(1)
      expect(stats.total_candidate_count(only: %i[recruited], phase: :apply_2)).to eq(1)
      expect(stats.total_candidate_count(except: %i[pending_conditions])).to eq(2)
    end
  end

  describe '#initialize' do
    it 'can filter by year' do
      create(:application_choice, status: 'recruited', application_form: create(:application_form, recruitment_cycle_year: 2020))
      create(:application_choice, status: 'recruited', application_form: create(:application_form, recruitment_cycle_year: 2021))

      stats = PerformanceStatistics.new(2021)

      expect(stats.total_candidate_count).to eq(1)
    end
  end

  describe '#percentage_of_providers_onboarded' do
    it 'returns the percentage of providers onboarded to the nearest whole number' do
      create(:provider)
      synced_providers = create_list(:provider, 2, sync_courses: true)
      create_list(:course, 3, provider: synced_providers.first, open_on_apply: true)

      stats = PerformanceStatistics.new(2021)

      expect(stats.percentage_of_providers_onboarded).to eq('33%')
    end

    it 'returns "-" when there are no providers' do
      stats = PerformanceStatistics.new(2021)

      expect(stats.percentage_of_providers_onboarded).to eq('-')
    end
  end

  describe '#rejected_by_default_count' do
    it 'returns the count of all rejected by default applications' do
      create(:application_choice, status: 'rejected', rejected_by_default: true, application_form: create(:application_form, recruitment_cycle_year: 2020))
      create_list(:application_choice, 2, status: 'rejected', rejected_by_default: true, application_form: create(:application_form, recruitment_cycle_year: 2021))
      create(:application_choice, status: 'rejected', rejected_by_default: false, application_form: create(:application_form, recruitment_cycle_year: 2021))

      stats = PerformanceStatistics.new(nil)

      expect(stats.rejected_by_default_count).to eq(2)
    end

    it 'returns the count of all rejected by default applications filtered by recruitment cycle year' do
      create(:application_choice, status: 'rejected', rejected_by_default: true, application_form: create(:application_form, recruitment_cycle_year: 2020))
      create_list(:application_choice, 2, status: 'rejected', rejected_by_default: true, application_form: create(:application_form, recruitment_cycle_year: 2021))
      create(:application_choice, status: 'rejected', rejected_by_default: false, application_form: create(:application_form, recruitment_cycle_year: 2021))

      stats = PerformanceStatistics.new(2021)

      expect(stats.rejected_by_default_count).to eq(1)
    end
  end

  def count_for_process_state(process_state)
    PerformanceStatistics.new(nil)[process_state]
  end

  it 'excludes candidates marked as hidden from reporting' do
    hidden_candidate = create(:candidate, hide_in_reporting: true)
    visible_candidate = create(:candidate, hide_in_reporting: false)
    create(:application_form, candidate: hidden_candidate)
    create(:application_form, candidate: visible_candidate)

    stats = PerformanceStatistics.new(nil)

    expect(stats.total_candidate_count).to eq(1)
  end
end
