require 'rails_helper'

RSpec.describe ChangeOffer do
  include CourseOptionHelpers

  let(:conditions) { [build(:offer_condition, text: 'DBS check')] }
  let(:application_choice) do
    create(:application_choice, :with_offer, offer: build(:offer, conditions: conditions))
  end
  let(:provider_user) do
    create(
      :provider_user,
      :with_make_decisions,
      providers: [application_choice.current_course_option.provider],
    )
  end
  let(:course_option) { course_option_for_provider(provider: application_choice.course_option.provider) }
  let(:new_conditions) { [Faker::Lorem.sentence] }
  let(:update_conditions_service) { instance_double(SaveOfferConditionsFromText, save: true, conditions: new_conditions) }

  let(:change_offer) do
    described_class.new(
      actor: provider_user,
      application_choice: application_choice,
      course_option: course_option,
      update_conditions_service: update_conditions_service,
    )
  end

  describe '#save!' do
    describe 'if the actor is not authorised to perform this action' do
      let(:provider_user) do
        create(:provider_user,
               providers: [application_choice.current_course_option.provider])
      end

      it 'throws an exception' do
        expect {
          change_offer.save!
        }.to raise_error(
          ProviderAuthorisation::NotAuthorisedError,
          'You do not have the required user level permissions to make decisions on applications for this provider.',
        )
      end
    end

    describe 'if the new offer is identical to the current offer' do
      let(:course_option) { application_choice.current_course_option }
      let(:new_conditions) { ['DBS check'] }

      it 'raises a ValidationException' do
        expect { change_offer.save! }.to raise_error(IdenticalOfferError)
      end
    end

    describe 'if the provided details are correct' do
      let(:application_choice) { create(:application_choice, status: :awaiting_provider_decision) }
      let(:provider_user) do
        create(:provider_user,
               :with_make_decisions,
               providers: [application_choice.course_option.provider])
      end

      it 'then it executes the service without errors ' do
        set_declined_by_default = instance_double(SetDeclineByDefault, call: true)
        allow(SetDeclineByDefault)
            .to receive(:new).with(application_form: application_choice.application_form)
                    .and_return(set_declined_by_default)

        change_offer.save!

        expect(update_conditions_service).to have_received(:save)
        expect(set_declined_by_default).to have_received(:call)
      end
    end

    describe 'audits', with_audited: true do
      it 'generates an audit event combining status change with current_course_option_id' do
        change_offer.save!

        audit_with_status_change = application_choice.reload.audits.find_by('jsonb_exists(audited_changes, ?)', 'status')
        expect(audit_with_status_change.audited_changes).to have_key('current_course_option_id')
      end
    end
  end
end
