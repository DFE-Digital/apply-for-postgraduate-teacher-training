require 'rails_helper'

RSpec.describe ImportReferencesFromCsv do
  let(:application_form) { FactoryBot.create(:completed_application_form, references_count: 0) }
  let(:first_reference) { FactoryBot.create(:reference, :unsubmitted, email_address: 'ab@c.com', application_form: application_form) }
  let(:second_reference) { FactoryBot.create(:reference, :unsubmitted, email_address: 'xy@z.com', application_form: application_form) }

  # Timestamp, Email Address, Your name, Name of the person, Feedback, Confirm, Application ID
  let(:csv_row) { ['2019', 'ab@c.com', 'My name', 'Their name', 'Feedback', 'I confirm', 'id'] }

  before do
    application_form.application_choices.each { |choice| choice.update(status: 'awaiting_references') }
    csv_row[6] = first_reference.id
  end

  describe 'processing a reference row from CSV' do
    it 'imports valid records from a CSV' do
      outcome = ImportReferencesFromCsv.process_row(csv_row)
      expect(outcome[:reference_id]).to eq(first_reference.id)
      expect(outcome[:updated]).to eq(true)
      expect(outcome[:errors]).to eq(nil)

      expect(application_form.references.find_by!(email_address: 'ab@c.com').feedback).to eq('Feedback')
      application_form.application_choices.each { |choice| expect(choice.status).to eq('awaiting_references') }
    end

    it 'imports multiple valid references for a single application' do
      ImportReferencesFromCsv.process_row(csv_row)
      csv_row[1] = 'xy@z.com'
      csv_row[4] = 'More feedback'
      csv_row[6] = second_reference.id
      ImportReferencesFromCsv.process_row(csv_row)

      expect(application_form.references.find_by!(email_address: 'ab@c.com').feedback).to eq('Feedback')
      expect(application_form.references.find_by!(email_address: 'xy@z.com').feedback).to eq('More feedback')
      expect(application_form).to be_references_complete
    end

    it 'does not change existing feedback' do
      ImportReferencesFromCsv.process_row(csv_row)

      csv_row[4] = 'Edited feedback'
      outcome = ImportReferencesFromCsv.process_row(csv_row)
      expect(outcome[:updated]).to eq(false)
      expect(outcome[:errors]).to eq(['Reference already has feedback'])

      expect(application_form.references.find_by!(email_address: 'ab@c.com').feedback).to eq('Feedback')
    end

    it 'does not update if an application form is not found' do
      csv_row[6] = 'not_an_id'
      outcome = ImportReferencesFromCsv.process_row(csv_row)

      expect(outcome[:reference_id]).to eq('not_an_id')
      expect(outcome[:updated]).to eq(false)
      expect(outcome[:errors]).to eq(["No application found for reference with ID 'not_an_id'"])
    end

    it 'does not update if the reference email is not associated with the application form' do
      csv_row[1] = 'not_a_valid_email@email.com'
      outcome = ImportReferencesFromCsv.process_row(csv_row)

      expect(outcome[:updated]).to eq(false)
      expect(outcome[:errors]).to eq(['Referee email does not match any of the provided referees'])
    end
  end
end
