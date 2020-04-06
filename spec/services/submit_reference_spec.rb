require 'rails_helper'

RSpec.describe SubmitReference do
  it 'progresses the application choices to the "application complete" status once all references have been received' do
    application_form = create(:completed_application_form)
    create(:application_choice, application_form: application_form, status: 'awaiting_references', edit_by: 1.day.from_now)
    create(:reference, :complete, application_form: application_form)
    reference = create(:reference, :unsubmitted, application_form: application_form)

    reference.update!(feedback: 'Trustworthy', relationship_correction: '', safeguarding_concerns: '')

    SubmitReference.new(
      reference: reference,
    ).save!

    expect(application_form.application_choices).to all(be_application_complete)
  end

  it 'progresses the application choices to the "awaiting_provider_decision" status once all references have been received if edit_by has elapsed' do
    application_form = create(:completed_application_form)
    create(:application_choice, application_form: application_form, status: 'awaiting_references', edit_by: 1.day.ago)
    create(:reference, :complete, application_form: application_form)
    reference = create(:reference, :unsubmitted, application_form: application_form)

    reference.update!(feedback: 'Trustworthy', relationship_correction: '', safeguarding_concerns: '')

    SubmitReference.new(
      reference: reference,
    ).save!

    expect(application_form.reload.application_choices).to all(be_awaiting_provider_decision)
  end

  it 'is okay with a 3rd reference being provided' do
    application_form = create(:completed_application_form)
    create(:application_choice, application_form: application_form, status: 'awaiting_references', edit_by: 1.day.ago)
    create(:reference, :complete, application_form: application_form)
    reference = create(:reference, :unsubmitted, application_form: application_form)

    reference.update!(feedback: 'Trustworthy', relationship_correction: '', safeguarding_concerns: '')

    SubmitReference.new(
      reference: reference,
    ).save!

    another_reference = create(:reference, :unsubmitted, application_form: application_form)

    another_reference.update!(feedback: 'Trustworthy', relationship_correction: '', safeguarding_concerns: '')

    SubmitReference.new(
      reference: another_reference,
    ).save!
  end
end
