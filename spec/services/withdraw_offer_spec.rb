require 'rails_helper'

RSpec.describe WithdrawOffer do
  describe '#save!' do
    it 'changes the state of the application_choice to "rejected" given a valid reason' do
      application_choice = create(:application_choice, status: :offer)

      withdrawal_reason = 'We are so sorry...'
      WithdrawOffer.new(
        actor: create(:support_user),
        application_choice: application_choice,
        offer_withdrawal_reason: withdrawal_reason,
      ).save

      expect(application_choice.reload.status).to eq 'offer_withdrawn'
    end

    it 'does not change the state of the application_choice to "rejected" without a valid reason' do
      application_choice = create(:application_choice, status: :offer)

      service = WithdrawOffer.new(
        actor: create(:support_user),
        application_choice: application_choice,
      )

      expect(service.save).to be false

      expect(application_choice.reload.status).to eq 'offer'
    end

    it 'raises an error if the user is not authorised' do
      application_choice = create(:application_choice, status: :offer)
      provider_user = create(:provider_user)
      provider_user.providers << application_choice.offered_course.provider

      FeatureFlag.activate(:providers_can_manage_users_and_permissions)

      service = WithdrawOffer.new(
        actor: provider_user,
        application_choice: application_choice,
        offer_withdrawal_reason: 'We are so sorry...',
      )

      expect { service.save }.to raise_error(ProviderAuthorisation::NotAuthorisedError)

      expect(application_choice.reload.status).to eq 'offer'
    end

    it 'calls SetDeclineByDefault given a valid reason' do
      application_choice = create(:application_choice, status: :offer)
      allow(SetDeclineByDefault).to receive(:new).and_call_original

      withdrawal_reason = 'We are so sorry...'
      WithdrawOffer.new(
        actor: create(:support_user),
        application_choice: application_choice,
        offer_withdrawal_reason: withdrawal_reason,
      ).save

      expect(SetDeclineByDefault).to have_received(:new).with(application_form: application_choice.application_form)
    end

    it 'calls StateChangeNotifier given a valid reason' do
      application_choice = create(:application_choice, status: :offer)
      allow(StateChangeNotifier).to receive(:call).and_return true

      withdrawal_reason = 'We are so sorry...'
      WithdrawOffer.new(
        actor: create(:support_user),
        application_choice: application_choice,
        offer_withdrawal_reason: withdrawal_reason,
      ).save

      expect(StateChangeNotifier).to have_received(:call).with(:withdraw_offer, application_choice: application_choice)
    end
  end
end
