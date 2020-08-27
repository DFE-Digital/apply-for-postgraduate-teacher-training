require 'rails_helper'

RSpec.describe FilterApplicationChoicesForProviders do
  include CourseOptionHelpers

  describe '#call' do
    let(:submitted_application_choice) { create(:application_choice, :awaiting_provider_decision, status: 'awaiting_provider_decision') }
    let(:offered_application_choice) { create(:application_choice, :with_offer, status: 'offer') }
    let(:accepted_application_choice) { create(:application_choice, :with_accepted_offer, status: 'pending_conditions') }
    let(:conditions_met_application_choice) { create(:application_choice, :awaiting_provider_decision, status: 'recruited') }
    let(:enrolled_application_choice) { create(:application_choice, status: 'enrolled') }
    let(:rejected_application_choice) { create(:application_choice, :with_rejection, status: 'rejected') }
    let(:declined_application_choice) { create(:application_choice, :with_declined_offer, status: 'declined') }
    let(:application_withdrawn_application_choice) { create(:application_choice, status: 'withdrawn') }
    let(:conditions_not_met_application_choice) { create(:application_choice, status: 'conditions_not_met') }
    let(:withdrawn_by_us_application_choice) { create(:application_choice, status: 'offer_withdrawn', offer_withdrawn_at: 2.days.ago) }

    context 'when filtering by status' do
      let(:application_choices) { ApplicationChoice.all }

      test_data =
        [
          { filter: 'Submitted', filter_status: 'awaiting_provider_decision' },
          { filter: 'Offered', filter_status: 'offer' },
          { filter: 'Accepted', filter_status: 'pending_conditions' },
          { filter: 'Conditions met', filter_status: 'recruited' },
          { filter: 'Enrolled', filter_status: 'enrolled' },
          { filter: 'Rejected', filter_status: 'rejected' },
          { filter: 'Declined', filter_status: 'declined' },
          { filter: 'Application withdrawn', filter_status: 'withdrawn' },
          { filter: 'Conditions not met', filter_status: 'conditions_not_met' },
          { filter: 'Offer withdrawn', filter_status: 'offer_withdrawn' },
        ]

      test_data.each_with_index do |example, index|
        it "single #{example[:filter]} filter returns only #{example[:filter].downcase} application choices" do
          returned_application_choices = described_class.call(
            application_choices: application_choices,
            filters: { status: [example[:filter_status]] },
          )
          ordered_expected_application_choices = [submitted_application_choice, offered_application_choice,
                                                  accepted_application_choice, conditions_met_application_choice,
                                                  enrolled_application_choice, rejected_application_choice,
                                                  declined_application_choice, application_withdrawn_application_choice,
                                                  conditions_not_met_application_choice, withdrawn_by_us_application_choice]

          expect(returned_application_choices).to eq([ordered_expected_application_choices[index]])
        end
      end
    end

    context 'when filtering by recruitment_cycle_year' do
      let(:application_choices) do
        create(:application_choice, :awaiting_provider_decision, :previous_year)
        create(:application_choice, :awaiting_provider_decision)
        ApplicationChoice.includes(:course).all
      end

      it 'ignores any filters if feature flag is off' do
        FeatureFlag.deactivate(:providers_can_filter_by_recruitment_cycle)

        returned_choices = described_class.call(
          application_choices: application_choices,
          filters: { recruitment_cycle_year: [RecruitmentCycle.previous_year] },
        )

        years_present = returned_choices.map(&:course).map(&:recruitment_cycle_year).uniq
        expect(years_present).to eq([RecruitmentCycle.previous_year, RecruitmentCycle.current_year])
      end

      it 'can show :previous_year applications if feature flag is on' do
        FeatureFlag.activate(:providers_can_filter_by_recruitment_cycle)

        returned_choices = described_class.call(
          application_choices: application_choices,
          filters: { recruitment_cycle_year: [RecruitmentCycle.previous_year] },
        )

        years_present = returned_choices.map(&:course).map(&:recruitment_cycle_year).uniq
        expect(years_present).to eq([RecruitmentCycle.previous_year])
      end

      it 'can show :current_year applications if feature flag is on' do
        FeatureFlag.activate(:providers_can_filter_by_recruitment_cycle)

        returned_choices = described_class.call(
          application_choices: application_choices,
          filters: { recruitment_cycle_year: [RecruitmentCycle.current_year] },
        )

        years_present = returned_choices.map(&:course).map(&:recruitment_cycle_year).uniq
        expect(years_present).to eq([RecruitmentCycle.current_year])
      end
    end
  end
end
