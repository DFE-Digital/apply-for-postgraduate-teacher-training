require 'rails_helper'

RSpec.describe ProviderInterface::InterviewAndCourseSummaryComponent do
  let(:interview) { create(:interview) }
  let(:component) { render_inline(described_class.new(interview: interview, user_can_change_interview: true)).text }

  it 'capitalises funding type' do
    expect(component).to include(interview.application_choice.course.funding_type.capitalize)
  end

  context 'interview preferences' do
    let(:application_choice) { create(:application_choice, :with_completed_application_form) }
    let(:interview) { create(:interview, application_choice: application_choice) }

    it 'displays interview preferences' do
      expect(component).to include(interview.application_choice.application_form.interview_preferences)
    end
  end

  it 'displays the provider name' do
    expect(component).to include(interview.application_choice.course.provider.name)
  end

  it 'displays the course name and code' do
    expect(component).to include(interview.application_choice.course.name_and_code)
  end

  it 'displays interview location' do
    expect(component).to include(interview.location)
  end

  context 'additional details' do
    it 'displays the additional details' do
      interview.additional_details = 'Test'
      expect(component).to include('Test')
    end

    it 'displays additional details as None when no additional details provided' do
      interview.additional_details = ''
      expect(component).to include('None')
    end
  end

  context 'user_can_change_interview is false' do
    let(:component) { render_inline(described_class.new(interview: interview, user_can_change_interview: false)).text }

    it 'does not render the edit or cancel buttons' do
      expect(component).not_to include('Change details')
      expect(component).not_to include('Cancel interview')
    end
  end
end
