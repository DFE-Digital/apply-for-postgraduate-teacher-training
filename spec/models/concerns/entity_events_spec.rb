require 'rails_helper'

# This spec is coupled to the Candidate model. I thought
# this was preferable to making an elaborate mock which
# didn't depend on the db
RSpec.describe EntityEvents do
  let(:interesting_fields) { [] }

  before do
    allow(Rails.configuration).to receive(:analytics).and_return({
      candidates: interesting_fields,
    })
  end

  describe 'create_entity events' do
    context 'when fields are specified in the analytics file' do
      let(:interesting_fields) { [:id] }

      it 'includes attributes specified in the settings file' do
        candidate = create(:candidate)

        expect(SendEventsToBigquery).to have_received(:perform_async)
          .with a_hash_including({
            'entity_table_name' => 'candidates',
            'event_type' => 'create_entity',
            'data' => [
              { 'key' => 'id', 'value' => [candidate.id] },
            ],
          })
      end

      it 'does not include attributes not specified in the settings file' do
        candidate = create(:candidate, course_from_find_id: 123)

        expect(SendEventsToBigquery).to have_received(:perform_async)
          .with a_hash_including({
            'entity_table_name' => 'candidates',
            'event_type' => 'create_entity',
            'data' => [
              { 'key' => 'id', 'value' => [candidate.id] },
              # ie the same payload as above
            ],
          })
      end

      it 'sends events that are valid according to the schema' do
        create(:candidate)

        expect(SendEventsToBigquery).to have_received(:perform_async) do |payload|
          schema = File.read('config/event-schema.json')
          schema_validator = JSONSchemaValidator.new(schema, payload)

          expect(schema_validator).to be_valid, schema_validator.failure_message
        end
      end
    end

    context 'when no fields are specified in the analytics file' do
      let(:interesting_fields) { [] }

      it 'does not send create_entity events at all' do
        create(:candidate)
        create(:email) # some other model, for example

        expect(SendEventsToBigquery).not_to have_received(:perform_async)
          .with(a_hash_including({ 'event_type' => 'create_entity' }))
      end
    end
  end

  describe 'update_entity events' do
    context 'when fields are specified in the analytics file' do
      let(:interesting_fields) { %i[email_address hide_in_reporting] }

      it 'sends update events for fields we care about' do
        candidate = create(:candidate, email_address: 'foo@bar.com')
        candidate.update(email_address: 'bar@baz.com')

        expect(SendEventsToBigquery).to have_received(:perform_async)
          .with a_hash_including({
            'entity_table_name' => 'candidates',
            'event_type' => 'update_entity',
            'data' => [
              { 'key' => 'email_address', 'value' => ['bar@baz.com'] },
              { 'key' => 'hide_in_reporting', 'value' => ['false'] },
            ],
          })
      end

      it 'does not send update events for fields we don’t care about' do
        candidate = create(:candidate)
        candidate.update(course_from_find_id: 1)

        expect(SendEventsToBigquery).not_to have_received(:perform_async)
          .with a_hash_including({
            'event_type' => 'update_entity',
          })
      end

      it 'sends events that are valid according to the schema' do
        candidate = create(:candidate)
        candidate.update(email_address: 'bar@baz.com')

        expect(SendEventsToBigquery).to have_received(:perform_async).twice do |payload|
          schema = File.read('config/event-schema.json')
          schema_validator = JSONSchemaValidator.new(schema, payload)

          expect(schema_validator).to be_valid, schema_validator.failure_message
        end
      end
    end

    context 'when no fields are specified in the analytics file' do
      let(:interesting_fields) { [] }

      it 'does not send update events at all' do
        candidate = create(:candidate)
        candidate.update(hide_in_reporting: true)

        expect(SendEventsToBigquery).not_to have_received(:perform_async)
          .with a_hash_including({
            'event_type' => 'update_entity',
          })
      end
    end
  end
end
