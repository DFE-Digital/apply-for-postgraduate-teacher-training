require 'rails_helper'

RSpec.describe SubmitReference do
  describe '#save!' do
    it 'updates the reference state to "feedback_provided" and sets feeedback_provided_at to the current time' do
      Timecop.freeze do
        application_choice = create(:application_choice, status: :unsubmitted)
        application_form = application_choice.application_form
        reference_one = create(:reference, :feedback_requested)
        reference_two = create(:reference, :feedback_requested, application_form: reference_one.application_form)

        SubmitReference.new(reference: reference_one).save!
        SubmitReference.new(reference: reference_two).save!

        expect(reference_one).to be_feedback_provided
        expect(reference_one.feedback_provided_at).to eq Time.zone.now
        expect(reference_two).to be_feedback_provided
        expect(reference_two.feedback_provided_at).to eq Time.zone.now
        expect(application_form.reload.application_choices).to all(be_unsubmitted)
      end
    end

    context 'when the second reference is received' do
      it 'cancels reference requests for all remaining "awaiting_feedback" references and sets references_completed to true' do
        application_form = create(:application_form)
        reference1 = create(:reference, :feedback_requested, application_form: application_form)
        reference2 = create(:reference, :feedback_requested, application_form: application_form)
        reference3 = create(:reference, :feedback_refused, application_form: application_form)
        reference4 = create(:reference, :feedback_requested, application_form: application_form)

        SubmitReference.new(reference: reference1).save!
        SubmitReference.new(reference: reference2).save!

        expect(reference1).to be_feedback_provided
        expect(reference2).to be_feedback_provided
        expect(reference3.reload).to be_feedback_refused
        expect(reference4.reload).to be_cancelled
        expect(application_form.reload.references_completed).to eq true
      end
    end
  end
end
