require 'rails_helper'

RSpec.describe ProviderMailer, type: :mailer do
  include CourseOptionHelpers

  subject(:mailer) { described_class }

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
      @course_option = course_option_for_provider_code(provider_code: 'ABC')
      @application_choice = create(:application_choice, status: 'application_complete', edit_by: Time.zone.today,
        course_option: @course_option,
        application_form:
          create(
            :completed_application_form,
            submitted_at: Time.zone.today,
        ))
      @provider_user = @application_choice.provider.provider_users.first
      @mail = mailer.application_submitted(@provider_user, @application_choice)
    end

    it 'sends an email with the correct subject' do
      expect(@mail.subject).to include(
        t('provider_application_submitted.email.subject',
          course_name: @application_choice.course.name,
           course_code: @application_choice.course.code),
          )
    end

    it 'addresses the provider user by name' do
      expect(@mail.body.encoded).to include("Dear #{@provider_user.full_name}")
    end

    it 'includes the candidate name' do
      expect(@mail.body.encoded).to include("#{@application_choice.application_form.full_name} submitted an application for")
    end

    it 'includes the course details' do
      expect(@mail.body.encoded).to include(@application_choice.course.name)
      expect(@mail.body.encoded).to include(@application_choice.course.code)
    end

    it 'includes a link to the application' do
      expect(@mail.body.encoded).to include(provider_interface_application_choice_url(application_choice_id: @application_choice.id))
    end
  end
end
