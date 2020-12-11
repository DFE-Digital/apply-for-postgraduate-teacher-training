require 'rails_helper'

RSpec.describe SupportInterface::SendUCASMatchInitialEmailsDuplicateApplications do
  describe '#call' do
    let(:course) { create(:course, recruitment_cycle_year: 2020) }
    let(:candidate) { create(:candidate) }
    let(:course_option) { create(:course_option, course: course) }
    let(:application_choice) { create(:application_choice, course_option: course_option) }
    let(:application_form) { create(:completed_application_form, candidate_id: candidate.id, application_choices: [application_choice]) }
    let(:ucas_match) { create(:ucas_match, recruitment_cycle_year: 2020, candidate: candidate, matching_data: [matching_data]) }
    let(:provider_user) { create(:provider_user) }
    let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    context 'when the application has a ucas_match' do
      describe 'when initial emails have not been sent' do
        let(:ucas_match) { create(:ucas_match, action_taken: 'initial_emails_sent', candidate: candidate) }

        it 'when the emails have already been sent it throws an exception' do
          expect { described_class.new(ucas_match).call }.to raise_error("Initial emails for UCAS match ##{ucas_match.id} were already sent")
        end
      end

      describe 'when the initial emails have not been sent already' do
        let(:matching_data) { { 'Scheme' => 'B', 'Course code' => course.code.to_s, 'Provider code' => course.provider.code.to_s, 'Apply candidate ID' => candidate.id.to_s } }

        before do
          application_form
          create(:provider_permissions, provider_id: course.provider.id, provider_user_id: provider_user.id)
          allow(CandidateMailer).to receive(:ucas_match_initial_email_duplicate_applications).and_return(mail)
          allow(ProviderMailer).to receive(:ucas_match_initial_email_duplicate_applications).and_return(mail)
          described_class.new(ucas_match).call
        end

        it 'sends the candidate the initial ucas_match email' do
          expect(CandidateMailer).to have_received(:ucas_match_initial_email_duplicate_applications).with(application_choice)
        end

        it 'sends the provider the ucas_match email' do
          expect(ProviderMailer).to have_received(:ucas_match_initial_email_duplicate_applications).with(provider_user, application_choice)
        end
      end
    end
  end
end
