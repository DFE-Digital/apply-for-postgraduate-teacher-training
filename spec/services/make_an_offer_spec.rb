require 'rails_helper'

RSpec.describe MakeAnOffer, sidekiq: true do
  let(:user) { SupportUser.new }

  describe 'course_option_id validation' do
    it 'accepts nil course_option_id' do
      decision = MakeAnOffer.new(
        actor: user,
        application_choice: build_stubbed(:application_choice, status: :awaiting_provider_decision),
        course_option_id: nil,
      )

      expect(decision).to be_valid
    end
  end

  describe 'conditions validation' do
    it 'accepts nil conditions' do
      decision = MakeAnOffer.new(
        actor: user,
        application_choice: build_stubbed(:application_choice, status: :awaiting_provider_decision),
        offer_conditions: nil,
      )

      expect(decision).to be_valid
    end

    it 'limits the number of conditions to 20' do
      decision = MakeAnOffer.new(
        actor: user,
        application_choice: build_stubbed(:application_choice, status: :awaiting_provider_decision),
        offer_conditions: Array.new(21) { 'a condition' },
      )

      expect(decision).not_to be_valid
    end

    it 'limits the length of individual further_conditions to 255 characters' do
      decision = MakeAnOffer.new(
        actor: user,
        application_choice: build_stubbed(:application_choice, status: :awaiting_provider_decision),
        further_conditions: { further_conditions2: 'a' * 256 },
      )

      expect(decision).not_to be_valid
    end
  end

  describe '#save' do
    it 'sets the offered_at date' do
      application_choice = create(:application_choice, status: :awaiting_provider_decision)

      MakeAnOffer.new(actor: user, application_choice: application_choice)

      Timecop.freeze do
        MakeAnOffer.new(actor: user, application_choice: application_choice).save

        expect(application_choice.offered_at).to eq(Time.zone.now)
      end
    end

    it 'sends an email to the candidate' do
      application_choice = create(:application_choice, status: :awaiting_provider_decision)

      MakeAnOffer.new(actor: user, application_choice: application_choice).save

      expect(CandidateMailer.deliveries.count).to be 1
    end
  end

  describe 'decline by default' do
    let(:application_form) { create :application_form }

    let(:application_choice) do
      create(:application_choice,
             application_form: application_form,
             status: 'awaiting_provider_decision')
    end

    it 'calls SetDeclineByDefault service' do
      MakeAnOffer.new(actor: user, application_choice: application_choice).save
      application_choice.reload

      expect(application_choice.decline_by_default_at).not_to be_nil
      expect(application_choice.decline_by_default_days).not_to be_nil
    end
  end

  describe 'offer a different course option' do
    let(:application_form) { create :application_form }

    let(:application_choice) do
      create(:application_choice,
             application_form: application_form,
             status: 'awaiting_provider_decision')
    end

    let(:different_course_option) { create(:course_option, course: application_choice.course) }

    it 'sets application_choice.offered_course_option_id' do
      MakeAnOffer.new(
        actor: user,
        application_choice: application_choice,
        course_option_id: different_course_option.id,
      ).save
      application_choice.reload

      expect(application_choice.offered_course_option_id).to eq(different_course_option.id)
    end
  end

  describe 'authorisation' do
    it 'raises error if actor is not authorised' do
      application_choice = create(:application_choice, status: :awaiting_provider_decision)
      unrelated_user = create(:provider_user, :with_provider)
      new_offer = MakeAnOffer.new(actor: unrelated_user, application_choice: application_choice)
      expect { new_offer.save }.to raise_error(ProviderAuthorisation::NotAuthorisedError)
    end

    it 'does not raise error if actor is authorised' do
      application_choice = create(:application_choice, status: :awaiting_provider_decision)
      related_user = create(:provider_user)
      application_choice.course.provider.provider_users << related_user
      new_offer = MakeAnOffer.new(actor: related_user, application_choice: application_choice)
      expect { new_offer.save }.not_to raise_error
    end

    it 'allows support users to make offers for any course' do
      application_choice = create(:application_choice, status: :awaiting_provider_decision)
      new_offer = MakeAnOffer.new(actor: SupportUser.new, application_choice: application_choice)
      expect { new_offer.save }.not_to raise_error
    end
  end
end
