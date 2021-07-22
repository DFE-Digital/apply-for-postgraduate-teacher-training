require 'rails_helper'

RSpec.describe ApplicationChoice, type: :model do
  describe 'auditing', with_audited: true do
    it 'creates audit entries' do
      application_choice = create :application_choice, status: 'unsubmitted'
      expect(application_choice.audits.count).to eq 1
      application_choice.update!(status: 'awaiting_provider_decision')
      expect(application_choice.audits.count).to eq 2
    end

    it 'creates an associated object in each audit record' do
      application_choice = create :application_choice
      expect(application_choice.audits.last.associated).to eq application_choice.application_form
    end

    it 'audit record can be attributed to a candidate' do
      candidate = create :candidate
      application_choice = Audited.audit_class.as_user(candidate) do
        create :application_choice
      end
      expect(application_choice.audits.last.user).to eq candidate
    end
  end

  describe '.decision_pending' do
    it 'returns nothing when there are no awaiting_provider_decision or interviewing application choices' do
      create(:application_choice, :with_offer)

      expect(described_class.decision_pending).to be_empty
    end

    it 'scopes to awaiting_provider_decision and interviewing application choices' do
      (ApplicationStateChange.valid_states - ApplicationStateChange::DECISION_PENDING_STATUSES).each do |state|
        create(:application_choice, status: state)
      end
      choice_awaiting_decision = create(:application_choice, :awaiting_provider_decision)
      interviewing_choice = create(:application_choice, status: :interviewing)

      expect(described_class.decision_pending).to contain_exactly(choice_awaiting_decision, interviewing_choice)
    end
  end

  describe '#decision_pending?' do
    it 'returns false for choices in states not requiring provider action' do
      (ApplicationStateChange.valid_states - ApplicationStateChange::DECISION_PENDING_STATUSES).each do |state|
        application_choice = build_stubbed(:application_choice, status: state)
        expect(application_choice.decision_pending?).to eq(false)
      end
    end

    it 'returns true for awaiting_provider_decision and interviewing application choices' do
      choice_awaiting_decision = build_stubbed(:application_choice, :awaiting_provider_decision)
      interviewing_choice = build_stubbed(:application_choice, :with_scheduled_interview)

      expect(choice_awaiting_decision.decision_pending?).to eq(true)
      expect(interviewing_choice.decision_pending?).to eq(true)
    end
  end

  describe '#course_full?' do
    context 'with 3 options all full' do
      it 'returns true' do
        course = create(:course)
        create_list(:course_option, 3, vacancy_status: :no_vacancies, course: course)
        application_choice = create(:application_choice, course_option: course.course_options.first)
        expect(application_choice.course_full?).to be true
      end
    end

    context 'with 2 options only 1 full' do
      it 'returns false' do
        course = create(:course)
        course_option_without_vacancies = create(:course_option, vacancy_status: :no_vacancies, course: course)
        create(:course_option, vacancy_status: :vacancies, course: course)
        application_choice = create :application_choice, course_option: course_option_without_vacancies
        expect(application_choice.course_full?).to be false
      end
    end
  end

  describe '#site_full?' do
    context 'with 3 options all full' do
      it 'returns true' do
        course = create(:course)
        create_list(:course_option, 3, vacancy_status: :no_vacancies, course: course)
        application_choice = create(:application_choice, course_option: course.course_options.first)
        expect(application_choice.site_full?).to be true
      end
    end

    context 'with 2 options only 1 full' do
      it 'returns true' do
        course = create(:course)
        course_option_without_vacancies = create(:course_option, vacancy_status: :no_vacancies, course: course)
        create(:course_option, vacancy_status: :vacancies, course: course)
        application_choice = create :application_choice, course_option: course_option_without_vacancies
        expect(application_choice.site_full?).to be true
      end
    end

    context 'with 2 options for same site only 1 full' do
      it 'returns true' do
        course = create(:course)
        site = create(:site, provider: course.provider)
        course_option_without_vacancies = create(:course_option, vacancy_status: :no_vacancies, course: course, site: site, study_mode: 'full_time')
        create(:course_option, vacancy_status: :vacancies, course: course, site: site, study_mode: 'part_time')
        application_choice = create :application_choice, course_option: course_option_without_vacancies
        expect(application_choice.site_full?).to be false
      end
    end
  end

  describe '#site_invalid?' do
    context 'a course option has been removed by the provider' do
      it 'returns true' do
        course_option = build(:course_option, site_still_valid: false)
        application_choice = create(:application_choice, course_option: course_option)
        expect(application_choice.site_invalid?).to be true
      end
    end

    context 'a course option is still valid' do
      it 'returns false' do
        course_option = build(:course_option, site_still_valid: true)
        application_choice = create(:application_choice, course_option: course_option)
        expect(application_choice.site_invalid?).to be false
      end
    end
  end

  describe '#course_study_mode_full?' do
    context 'with option that has vacancies' do
      it 'returns false' do
        course = create(:course)
        create(:course_option, vacancy_status: :vacancies, course: course)
        application_choice = create(:application_choice, course_option: course.course_options.first)
        expect(application_choice.study_mode_full?).to be false
      end
    end

    context 'with 2 options only 1 full' do
      it 'returns true' do
        course = create(:course)
        course_option_without_vacancies = create(:course_option, vacancy_status: :no_vacancies, course: course)
        create(:course_option, vacancy_status: :vacancies, course: course)
        application_choice = create :application_choice, course_option: course_option_without_vacancies
        expect(application_choice.study_mode_full?).to be true
      end
    end

    context 'with 2 options for same site only 1 full' do
      it 'returns true' do
        course = create(:course)
        site = create(:site, provider: course.provider)
        course_option_without_vacancies = create(:course_option, vacancy_status: :no_vacancies, course: course, site: site, study_mode: 'full_time')
        create(:course_option, vacancy_status: :vacancies, course: course, site: site, study_mode: 'part_time')
        application_choice = create :application_choice, course_option: course_option_without_vacancies
        expect(application_choice.study_mode_full?).to be true
      end
    end
  end

  describe '#no_feedback?' do
    it 'returns false if simple rejection reason is provided' do
      application_choice = build(:application_choice, :with_rejection)

      expect(application_choice.no_feedback?).to be false
    end

    it 'returns false if structured rejection reasons are provided' do
      application_choice = build(:application_choice, :with_structured_rejection_reasons)

      expect(application_choice.no_feedback?).to be false
    end

    it 'returns true if no feedback for the candidate is provided' do
      application_choice = build(:application_choice)

      expect(application_choice.no_feedback?).to be true
    end
  end

  describe 'validations' do
    subject(:application_choice) { create(:application_choice) }

    it { is_expected.to validate_uniqueness_of(:course_option).scoped_to(:application_form_id) }
  end

  describe '#structured_rejection_reasons' do
    it 'are serialized and rehydrateable' do
      reasons = ReasonsForRejection.new(
        candidate_behaviour_y_n: 'Yes',
        candidate_behaviour_what_did_the_candidate_do: %w[other],
        candidate_behaviour_other: 'Used the wrong spoon for soup',
      )

      application_choice = create(:application_choice)
      application_choice.update!(structured_rejection_reasons: reasons)

      rehydrated_reasons = ReasonsForRejection.new(application_choice.reload.structured_rejection_reasons)
      expect(rehydrated_reasons.candidate_behaviour_y_n).to eq('Yes')
      expect(rehydrated_reasons.candidate_behaviour_what_did_the_candidate_do).to eq(%w[other])
      expect(rehydrated_reasons.candidate_behaviour_other).to eq('Used the wrong spoon for soup')
    end
  end

  describe '#associated_providers' do
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option: course_option) }
    let(:course_option) { create(:course_option, course: course) }
    let(:provider) { create(:provider) }
    let(:provider_user) { create(:provider_user, :with_make_decisions, providers: [provider]) }
    let(:accredited_provider) { create(:provider) }

    context 'when the application course has both a provider and an accredited provider' do
      let(:course) { create(:course, provider: provider) }

      it 'retrieves both providers' do
        expect(application_choice.associated_providers).to contain_exactly(provider)
      end
    end

    context 'when the application course only has a provider set' do
      let(:course) { create(:course, provider: provider, accredited_provider: accredited_provider) }

      it 'retrieves the ratifying provider' do
        expect(application_choice.associated_providers).to contain_exactly(provider, accredited_provider)
      end
    end

    context 'when the application course provider and accredited provider are the same' do
      let(:course) { create(:course, provider: provider, accredited_provider: provider) }

      it 'retrieves the training provider' do
        expect(application_choice.associated_providers).to contain_exactly(provider)
      end
    end
  end

  describe '#unconditional_offer_pending_recruitment?' do
    context 'recruited with conditions' do
      it 'returns false' do
        application_choice = build_stubbed(:application_choice, :with_recruited)
        expect(application_choice.unconditional_offer_pending_recruitment?).to eq false
      end
    end

    context 'recruited unconditionally' do
      it 'returns true' do
        application_choice = build_stubbed(:application_choice, :with_recruited, offer: create(:unconditional_offer))

        expect(application_choice.unconditional_offer_pending_recruitment?).to eq true
      end
    end

    context 'all other statuses' do
      it 'returns false' do
        statuses = ApplicationChoice.statuses.values.reject { |value| value == 'recruited' }

        statuses.each do |status|
          application_choice = build_stubbed(:application_choice, status: status)
          expect(application_choice.unconditional_offer_pending_recruitment?).to eq false
        end
      end
    end
  end

  describe '#unconditional_offer' do
    context 'when the offer has no conditions' do
      it 'returns true' do
        application_choice = build_stubbed(:application_choice, :with_recruited, offer: create(:unconditional_offer))

        expect(application_choice.unconditional_offer?).to be true
      end
    end

    context 'when the offer has conditions' do
      it 'returns false' do
        application_choice = build_stubbed(:application_choice, :with_offer, offer: create(:offer))

        expect(application_choice.unconditional_offer?).to be false
      end
    end
  end

  describe '#withdrawn_at_candidates_request?' do
    it 'is false when the application has been withdrawn by the candidate' do
      application_choice = build_stubbed(:application_choice, :withdrawn)

      expect(application_choice.withdrawn_at_candidates_request?).to be false
    end

    it 'is true when the application has been withdrawn at the candidate\'s request' do
      application_choice = build_stubbed(:application_choice, :withdrawn)
      create(:withdrawn_at_candidates_request_audit, application_choice: application_choice)

      expect(application_choice.withdrawn_at_candidates_request?).to be true
    end
  end
end
