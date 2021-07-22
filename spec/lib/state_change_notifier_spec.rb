require 'rails_helper'

RSpec.describe StateChangeNotifier do
  let(:helpers) { Rails.application.routes.url_helpers }

  before { allow(SlackNotificationWorker).to receive(:perform_async) }

  describe '#call' do
    let(:candidate)           { create(:candidate) }
    let(:application_choice)  { create(:application_choice) }
    let(:applicant)           { application_choice.application_form.first_name }
    let(:provider_name)       { application_choice.course.provider.name }
    let(:application_form)    { application_choice.application_form }
    let(:application_form_id) { application_choice.application_form.id }
    let(:course_name)         { application_choice.course.name_and_code }

    describe ':change_an_offer' do
      before { StateChangeNotifier.call(:change_an_offer, application_choice: application_choice) }

      it 'mentions applicant\'s first name and provider name' do
        arg1 = ":love_letter: #{provider_name} has changed an offer for #{applicant}’s application"
        expect(SlackNotificationWorker).to have_received(:perform_async).with(arg1, anything)
      end

      it 'links the notification to the relevant support_interface application_form' do
        arg2 = helpers.support_interface_application_form_url(application_form_id)
        expect(SlackNotificationWorker).to have_received(:perform_async).with(anything, arg2)
      end
    end
  end

  describe '.sign_up' do
    let(:candidate_count) { 0 }

    before do
      fake_relation = instance_double('ActiveRecord::Relation', count: candidate_count)
      allow(Candidate).to receive(:where).and_return fake_relation
      StateChangeNotifier.sign_up(create(:candidate))
    end

    context 'every 100 candidate' do
      let(:candidate_count) { 200 }

      it 'reports the sign up' do
        expect(SlackNotificationWorker).to have_received(:perform_async).with(/sparkles.+200th candidate/, anything)
      end
    end

    context 'every 500th candidate' do
      let(:candidate_count) { 1000 }

      it 'reports the sign up' do
        expect(SlackNotificationWorker).to have_received(:perform_async).with(/ultrafastparrot.+1,000th candidate/, anything)
      end
    end

    context 'counts over 1000' do
      let(:candidate_count) { 1500 }

      it 'reports the sign up' do
        expect(SlackNotificationWorker).to have_received(:perform_async).with(/1,500th candidate/, anything)
      end
    end
  end

  describe '.application_outcome_notification' do
    let(:application_form) { build(:completed_application_form) }
    let(:applicant) { application_form.first_name }
    let(:provider_name) { application_choice.provider.name }
    let(:rejected_choice) { create(:application_choice, :with_rejection, application_form: application_form) }
    let(:rejected_by_default_choice) { create(:application_choice, :with_rejection, rejected_by_default: true, application_form: application_form) }
    let(:declined_choice) { create(:application_choice, :with_declined_offer, application_form: application_form) }
    let(:declined_by_default_choice) { create(:application_choice, :with_declined_offer, declined_by_default: true, application_form: application_form) }
    let(:withdrawn_choice) { create(:application_choice, :withdrawn, application_form: application_form) }

    context ':rejected' do
      let(:application_choice) { create(:application_choice, :with_rejection, application_form: application_form) }

      it 'all rejected' do
        rejected_choice

        StateChangeNotifier.new(:rejected, application_choice).application_outcome_notification

        message = /:broken_heart: #{applicant}'s application was rejected by #{provider_name} and #{rejected_choice.provider.name}/
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end
    end

    context ':rejected_by_default' do
      let(:application_choice) { create(:application_choice, :with_rejection, rejected_by_default: true, application_form: application_form) }

      it 'all rejected by default' do
        rejected_by_default_choice

        StateChangeNotifier.new(:rejected_by_default, application_choice).application_outcome_notification

        message = /:broken_heart: #{applicant}'s applications to #{provider_name} and #{rejected_by_default_choice.provider.name} were rejected by default/
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end
    end

    context ':declined' do
      let(:application_choice) { create(:application_choice, :declined, application_form: application_form) }

      it 'all declined' do
        declined_choice

        StateChangeNotifier.new(:declined, application_choice).application_outcome_notification

        message = /:no_good: #{applicant} declined offers from #{provider_name} and #{declined_choice.provider.name}/
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end
    end

    context ':declined_by_default' do
      let(:application_choice) { create(:application_choice, :declined, declined_by_default: true, application_form: application_form) }

      it 'all declined_by_default' do
        declined_by_default_choice

        StateChangeNotifier.new(:declined_by_default, application_choice).application_outcome_notification

        message = /:no_good: #{applicant} declined by default offers from #{provider_name} and #{declined_by_default_choice.provider.name}/
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end
    end

    context ':withdrawn' do
      let(:application_choice) { create(:application_choice, :withdrawn, application_form: application_form) }

      it 'all withdrawn' do
        withdrawn_choice

        StateChangeNotifier.new(:withdrawn, application_choice).application_outcome_notification

        message = /:runner: #{applicant} withdrew their applications from #{provider_name} and #{withdrawn_choice.provider.name}/
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end
    end

    context ':recruited' do
      let(:application_choice) { create(:application_choice, :recruited, application_form: application_form) }

      it 'and no other applications' do
        StateChangeNotifier.new(:recruited, application_choice).application_outcome_notification

        message = /:handshake: #{applicant} was recruited to #{provider_name}/
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end
    end

    context ':withdrawn_at_candidates_request' do
      let(:application_choice) { create(:application_choice, :withdrawn, application_form: application_form) }

      it 'sends a job to the worker when all applications are withdrawn at candidate\'s request' do
        create(:withdrawn_at_candidates_request_audit, application_choice: withdrawn_choice)
        create(:withdrawn_at_candidates_request_audit, application_choice: application_choice)

        StateChangeNotifier.new(:withdrawn_at_candidates_request, application_choice).application_outcome_notification

        message = /:runner: #{applicant} requested that their applications be withdrawn from #{provider_name} and #{withdrawn_choice.provider.name}/
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end
    end

    context 'any last action with random other application state combinations' do
      let(:status_params) do
        {
          rejected_by_default: { status: 'rejected', rejected_by_default: true },
          declined_by_default: { status: 'declined', declined_by_default: true },
        }
      end

      let(:application_choice) { create(:application_choice, application_form: application_form) }

      it 'other applications have been rejected' do
        status = (StateChangeNotifier::APPLICATION_OUTCOME_EVENTS - %i[rejected withdrawn_at_candidates_request]).sample
        params = status_params.key?(status) ? status_params[status] : { status: status }
        application_choice.update(params)

        rejected_choice

        StateChangeNotifier.new(status.to_sym, application_choice).application_outcome_notification

        message = /.+#{applicant} previously was rejected by #{rejected_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been declined' do
        status = (StateChangeNotifier::APPLICATION_OUTCOME_EVENTS - %i[declined withdrawn_at_candidates_request]).sample
        params = status_params.key?(status) ? status_params[status] : { status: status }
        application_choice.update(params)

        declined_choice

        StateChangeNotifier.new(status.to_sym, application_choice).application_outcome_notification

        message = /.+#{applicant} previously declined an offer from #{declined_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been withdrawn' do
        status = (StateChangeNotifier::APPLICATION_OUTCOME_EVENTS - %i[withdrawn withdrawn_at_candidates_request]).sample
        params = status_params.key?(status) ? status_params[status] : { status: status }
        application_choice.update(params)

        withdrawn_choice

        StateChangeNotifier.new(status.to_sym, application_choice).application_outcome_notification

        message = /.+#{applicant} previously withdrew from #{withdrawn_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been rejected, declined and withdrawn' do
        status = (StateChangeNotifier::APPLICATION_OUTCOME_EVENTS - %i[withdrawn rejected declined withdrawn_at_candidates_request]).sample
        params = status_params.key?(status) ? status_params[status] : { status: status }
        application_choice.update(params)

        rejected_choice
        declined_choice
        withdrawn_choice

        StateChangeNotifier.new(status.to_sym, application_choice).application_outcome_notification

        message = /.+#{applicant} previously declined an offer from #{declined_choice.provider.name}, withdrew from #{withdrawn_choice.provider.name}, and was rejected by #{rejected_choice.provider.name}/
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been declined, declined_by_default, rejected, rejected_by_default and withdrawn' do
        status = (StateChangeNotifier::APPLICATION_OUTCOME_EVENTS - %i[withdrawn rejected rejected_by_default declined declined_by_default withdrawn_at_candidates_request]).sample
        params = status_params.key?(status) ? status_params[status] : { status: status }
        application_choice.update(params)

        withdrawn_choice
        declined_choice
        rejected_choice
        rejected_by_default_choice
        declined_by_default_choice

        StateChangeNotifier.new(status.to_sym, application_choice).application_outcome_notification

        message = /.+#{applicant} previously declined an offer from #{declined_choice.provider.name}, declined by default an offer from #{declined_by_default_choice.provider.name}, withdrew from #{withdrawn_choice.provider.name}, was rejected by #{rejected_choice.provider.name}, and was rejected by default from #{rejected_by_default_choice.provider.name}/
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been withdrawn at the candidate\'s request' do
        application_choice.update(status: 'rejected')

        create(:withdrawn_at_candidates_request_audit, application_choice: declined_choice, comment: 'Declined on behalf of the candidate')
        create(:withdrawn_at_candidates_request_audit, application_choice: withdrawn_choice)

        StateChangeNotifier.new(:rejected, application_choice).application_outcome_notification

        message = /:broken_heart: #{applicant}'s application was rejected by #{application_choice.provider.name}. #{applicant} previously requested that their applications be withdrawn from #{withdrawn_choice.provider.name} and #{declined_choice.provider.name}/
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'ignores other applications with statuses not included in outcome list' do
        recruited_application_choice = create(:application_choice, :recruited, application_form: application_form)

        # application with status not in outcome list
        create(:application_choice, :awaiting_provider_decision, application_form: application_form)
        rejected_choice

        StateChangeNotifier.new(:recruited, recruited_application_choice).application_outcome_notification

        message = /:handshake: #{applicant} was recruited to #{recruited_application_choice.provider.name}. #{applicant} previously was rejected by #{rejected_choice.provider.name}/
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end
    end
  end
end
