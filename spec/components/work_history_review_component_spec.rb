require 'rails_helper'

RSpec.describe WorkHistoryReviewComponent do
  let(:data) do
    {
      role: ['Teacher', 'Teaching Assistant'].sample,
      organisation: Faker::Educator.secondary_school,
      details: Faker::Lorem.paragraph_by_chars(number: 300),
      commitment: %w[full_time part_time].sample,
      working_with_children: [true, true, true, false].sample,
    }
  end

  context 'when there is not a break in the work history' do
    it 'renders component with correct structure' do
      application_form = create(:application_form) do |form|
        data[:id] = 1
        data[:start_date] = Time.zone.local(2019, 1, 1)
        data[:end_date] = Time.zone.local(2019, 6, 1)
        form.application_work_experiences.create(data)

        data[:id] = 2
        data[:start_date] = Time.zone.local(2019, 6, 1)
        data[:end_date] = Time.zone.local(2019, 8, 1)
        form.application_work_experiences.create(data)

        data[:id] = 3
        data[:start_date] = Time.zone.local(2019, 8, 1)
        data[:end_date] = Time.zone.local(2019, 10, 1)
        form.application_work_experiences.create(data)
      end

      result = render_inline(WorkHistoryReviewComponent, application_form: application_form)

      application_form.application_work_experiences.each do |work|
        expect(result.text).to include(work.role)
        expect(result.text).to include(work.start_date.strftime('%B %Y'))
        if work.working_with_children
          expect(result.text).to include(t('application_form.work_history.working_with_children'))
        end
      end
    end
  end

  context 'when there are breaks in the work history' do
    it 'renders summary card for breaks in the work history' do
      Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
        application_form = create(:application_form) do |form|
          data[:id] = 1
          data[:start_date] = Time.zone.local(2019, 8, 1)
          data[:end_date] = Time.zone.local(2019, 9, 1)
          form.application_work_experiences.create(data)

          form.work_history_breaks = 'WE WERE ON A BREAK!'
        end

        result = render_inline(WorkHistoryReviewComponent, application_form: application_form)

        expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.work_history.break.label'))
        expect(result.css('.govuk-summary-list__value').to_html).to include('WE WERE ON A BREAK!')
        expect(result.css('.govuk-summary-list__actions a')[4].attr('href')).to include(
          Rails.application.routes.url_helpers.candidate_interface_work_history_breaks_path,
        )
        expect(result.css('.govuk-summary-list__actions').text).to include(t('application_form.work_history.break.enter_label'))
      end
    end
  end
end
