require 'rails_helper'

RSpec.describe ProviderInterface::ChangeOfferForm do
  include CourseOptionHelpers
  let(:provider_user) { create(:provider_user, :with_provider) }
  let(:provider) { provider_user.providers.first }
  let(:course) { create(:course, :open_on_apply, provider: provider) }
  let(:course_option) { course_option_for_provider(provider: provider, course: course) }
  let(:application_choice) { create(:application_choice, :with_modified_offer, course_option: course_option) }
  let(:form_with_application_choice) { described_class.new(application_choice: application_choice, step: step) }

  def invalid_for_missing(attribute)
    form_with_application_choice.provider_id = course_option.course.provider.id
    form_with_application_choice.course_id = course_option.course.id
    form_with_application_choice.course_option_id = course_option.id
    form_with_application_choice.send("#{attribute}=".to_sym, nil)
    expect(form_with_application_choice).to be_invalid
  end

  describe 'validations common to each step' do
    it { is_expected.to validate_presence_of(:application_choice) }
    it { is_expected.to validate_presence_of(:step) }
  end

  describe 'step: :provider' do
    let(:step) { :provider }
    let(:subject) { form_with_application_choice }

    it { is_expected.to be_valid }
  end

  describe 'step: :course' do
    let(:step) { :course }
    let(:subject) { form_with_application_choice }

    it 'is valid when provider_id is set' do
      form_with_application_choice.provider_id = 'any value'
      expect(form_with_application_choice).to be_valid
    end

    %w[provider_id].each do |attribute|
      it "is invalid when :#{attribute} is missing" do
        invalid_for_missing attribute
      end
    end
  end

  describe 'step: :course_option' do
    let(:step) { :course_option }
    let(:subject) { form_with_application_choice }

    it 'is valid when provider_id and course_id are set and related' do
      form_with_application_choice.provider_id = course.provider.id
      form_with_application_choice.course_id = course.id
      expect(form_with_application_choice).to be_valid
    end

    %w[provider_id course_id].each do |attribute|
      it "is invalid when :#{attribute} is missing" do
        invalid_for_missing attribute
      end
    end

    it 'is invalid when provider_id and course_id are set but not related' do
      form_with_application_choice.provider_id = 458
      form_with_application_choice.course_id = course.id
      expect(form_with_application_choice).to be_invalid
    end
  end

  describe 'step: :confirm' do
    let(:step) { :confirm }
    let(:subject) { form_with_application_choice }

    it 'is valid when provider_id, course_id and course_option_id are all set and related' do
      form_with_application_choice.provider_id = course_option.course.provider.id
      form_with_application_choice.course_id = course_option.course.id
      form_with_application_choice.course_option_id = course_option.id
      expect(form_with_application_choice).to be_valid
    end

    %w[provider_id course_id course_option_id].each do |attribute|
      it "is invalid when :#{attribute} is missing" do
        invalid_for_missing attribute
      end
    end

    it 'is invalid when provider_id, course_id, course_option_id are set but not related' do
      form_with_application_choice.provider_id = course_option.course.provider.id
      form_with_application_choice.course_id = course_option.course.id
      form_with_application_choice.course_option_id = create(:course_option).id
      expect(form_with_application_choice).to be_invalid
    end
  end

  describe 'step: :update' do
    let(:step) { :update }
    let(:subject) { form_with_application_choice }

    it 'is valid when provider_id, course_id and course_option_id are all set and related' do
      form_with_application_choice.provider_id = course_option.course.provider.id
      form_with_application_choice.course_id = course_option.course.id
      form_with_application_choice.course_option_id = course_option.id
      expect(form_with_application_choice).to be_valid
    end

    %w[provider_id course_id course_option_id].each do |attribute|
      it "is invalid when :#{attribute} is missing" do
        invalid_for_missing attribute
      end
    end
  end
end
