require 'rails_helper'

RSpec.describe CandidateInterface::OfferReviewComponent do
  include CourseOptionHelpers

  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }
  let(:application_form) { create(:application_form, submitted_at: Time.zone.now) }
  let(:conditions) { [build(:offer_condition, text: 'Fitness to train to teach check'), build(:offer_condition, text: 'Be cool')] }
  let(:application_choice) do
    create(:application_choice,
           :with_offer,
           offer: build(:offer, conditions: conditions),
           course_option: course_option,
           application_form: application_form)
  end

  it 'renders component with correct values for the provider' do
    result = render_inline(described_class.new(course_choice: application_choice))

    expect(result.css('.govuk-summary-list__key').text).to include('Provider')
    expect(result.css('.govuk-summary-list__value').text).to include(course_option.course.provider.name)
  end

  context 'when Find is open' do
    it 'renders component with correct values for the course' do
      Timecop.freeze(CycleTimetable.find_opens + 1.hour) do
        result = render_inline(described_class.new(course_choice: application_choice))

        expect(result.css('.govuk-summary-list__key').text).to include('Course')
        expect(result.css('.govuk-summary-list__value').text).to include(
          "#{course_option.course.name} (#{course_option.course.code})",
        )
        expect(result.css('a').to_html).to include(course_option.course.find_url)
      end
    end
  end

  context 'when Find is closed' do
    it 'renders component with correct values for the course' do
      Timecop.freeze(CycleTimetable.find_closes) do
        result = render_inline(described_class.new(course_choice: application_choice))

        expect(result.css('.govuk-summary-list__key').text).to include('Course')
        expect(result.css('.govuk-summary-list__value').text).to include(
          "#{course_option.course.name} (#{course_option.course.code})",
        )
        expect(result.css('a').to_html).not_to include(course_option.course.find_url)
      end
    end
  end

  it 'renders component with correct values for the location' do
    result = render_inline(described_class.new(course_choice: application_choice))

    expect(result.css('.govuk-summary-list__value').text).to include(course_option.site.name)
  end

  context 'when there are conditions' do
    it 'renders component with correct values for the conditions' do
      result = render_inline(described_class.new(course_choice: application_choice))

      expect(result.css('.govuk-summary-list__key').text).to include('Conditions')
      expect(result.css('.govuk-summary-list__value').text).to include('Fitness to train to teach')
      expect(result.css('.govuk-summary-list__value').text).to include('Be cool')
    end
  end

  context 'when there are no conditions' do
    let(:application_choice) do
      create(:application_choice,
             :with_offer,
             offer: build(:unconditional_offer),
             course_option: course_option,
             application_form: application_form)
    end

    it 'does not render a conditions row' do
      result = render_inline(described_class.new(course_choice: application_choice))

      expect(result.css('.govuk-summary-list__key').text).not_to include('Conditions')
    end
  end
end
