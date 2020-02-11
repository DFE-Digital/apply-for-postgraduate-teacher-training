require 'rails_helper'

RSpec.describe ProviderMailer, type: :mailer do
  include CourseOptionHelpers

  subject(:mailer) { described_class }

  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }
  let(:application_choice) do
    build_stubbed(:submitted_application_choice,
                  course_option: course_option,
                  reject_by_default_days: 123,
                  application_form:
                    build_stubbed(
                      :completed_application_form,
                   ))
  end
  let(:provider_user) { application_choice.provider.provider_users.first }

  describe 'Send account created email' do
    before do
      @provider_user = build_stubbed(:provider_user)
      @mail = mailer.account_created(@provider_user)
    end

    it 'sends an email with the correct subject' do
      expect(@mail.subject).to include(t('provider_account_created.email.subject'))
    end

    it 'addresses the provider by name' do
      expect(@mail.body.encoded).to include("Dear #{@provider_user.full_name}")
    end

    it 'includes a link to the provider home page' do
      expect(@mail.body.encoded).to include(provider_interface_url)
    end
  end

  describe 'Send application submitted email' do
    before do
      @mail = mailer.application_submitted(provider_user, application_choice)
    end

    it 'sends an email with the correct subject' do
      expect(@mail.subject).to include(
        t('provider_application_submitted.email.subject',
          course_name_and_code: application_choice.course.name_and_code),
      )
    end

    it 'addresses the provider user by name' do
      expect(@mail.body.encoded).to include("Dear #{provider_user.full_name}")
    end

    it 'includes the candidate name' do
      expect(@mail.body.encoded).to include("#{application_choice.application_form.full_name} submitted an application for")
    end

    it 'includes the course details' do
      expect(@mail.body.encoded).to include(application_choice.course.name)
      expect(@mail.body.encoded).to include(application_choice.course.code)
    end

    it 'includes the reject by default days' do
      expect(@mail.body.encoded).to include('after 123 working days')
    end

    it 'includes a link to the application' do
      expect(@mail.body.encoded).to include(provider_interface_application_choice_url(application_choice))
    end
  end

  describe 'Send application rejected by default email' do
    before do
      @mail = mailer.application_rejected_by_default(provider_user, application_choice)
    end

    it 'sends an email with the correct subject' do
      expect(@mail.subject).to include(
        t('provider_application_rejected_by_default.email.subject',
          candidate_name: application_choice.application_form.full_name),
        )
    end

    it 'addresses the provider user by name' do
      expect(@mail.body.encoded).to include("Dear #{provider_user.full_name}")
    end

    it 'includes the candidate name' do
      expect(@mail.body.encoded).to include("#{application_choice.application_form.full_name} submitted an application for")
    end

    it 'includes the course details' do
      expect(@mail.body.encoded).to include(application_choice.course.name)
      expect(@mail.body.encoded).to include(application_choice.course.code)
    end

    it 'includes a readable submission date' do
      submission_date = application_choice.application_form.submitted_at
      expect(@mail.body.encoded).to include("on #{submission_date.to_s(:govuk_date).strip}")
    end

    it 'includes a link to the application' do
      expect(@mail.body.encoded).to include(provider_interface_application_choice_url(application_choice_id: application_choice.id))
    end
  end

  describe 'Send provider decision chaser email' do
    before do
      @mail = mailer.chase_provider_decision(provider_user, application_choice)
    end

    it 'sends an email with the correct subject' do
      expect(@mail.subject).to include(
        t('provider_application_waiting_for_decision.email.subject',
          candidate_name: application_choice.application_form.full_name),
        )
    end

    it 'addresses the provider user by name' do
      expect(@mail.body.encoded).to include("Dear #{provider_user.full_name}")
    end

    it 'includes the candidate name' do
      expect(@mail.body.encoded).to include("#{application_choice.application_form.full_name} submitted an application for")
    end

    it 'includes the time limit when we start chasing providers' do
      expected_days_left = "Only #{TimeLimitConfig.limits_for(:chase_provider_before_rbd).first.limit} working days left to respond"
      expect(@mail.body.encoded).to include(expected_days_left)
    end

    it 'includes the course details' do
      expect(@mail.body.encoded).to include(application_choice.course.name)
      expect(@mail.body.encoded).to include(application_choice.course.code)
    end

    it 'includes a readable submission date' do
      submission_date = application_choice.application_form.submitted_at
      expect(@mail.body.encoded).to include("on #{submission_date.to_s(:govuk_date).strip}")
    end

    it 'includes a link to the application' do
      expect(@mail.body.encoded).to include(provider_interface_application_choice_url(application_choice_id: application_choice.id))
    end

    it 'includes a readable RBD date' do
      rbd_date = application_choice.reject_by_default_at
      expect(@mail.body.encoded).to include("by #{rbd_date.to_s(:govuk_date).strip}")
    end
  end
end
