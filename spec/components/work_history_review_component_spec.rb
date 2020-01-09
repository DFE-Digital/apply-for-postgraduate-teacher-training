require 'rails_helper'

RSpec.describe WorkHistoryReviewComponent do
  let(:data) do
    {
      role: 'Teaching Assistant',
      organisation: Faker::Educator.secondary_school,
      details: Faker::Lorem.paragraph_by_chars(number: 300),
      commitment: %w[full_time part_time].sample,
      working_with_children: [true, true, true, false].sample,
    }
  end

  context 'when there is not a break in the work history' do
    let(:application_form) do
      create(:application_form) do |form|
        data[:organisation] = 'Vararu School'
        data[:start_date] = Time.zone.local(2019, 1, 1)
        data[:end_date] = Time.zone.local(2019, 6, 1)
        form.application_work_experiences.create(data)

        data[:organisation] = 'Theo School'
        data[:start_date] = Time.zone.local(2019, 6, 1)
        data[:end_date] = Time.zone.local(2019, 8, 1)
        form.application_work_experiences.create(data)

        data[:organisation] = 'Vararu School'
        data[:start_date] = Time.zone.local(2019, 8, 1)
        data[:end_date] = Time.zone.local(2019, 10, 1)
        form.application_work_experiences.create(data)
      end
    end

    context 'when jobs are editable' do
      it 'renders component with correct structure' do
        result = render_inline(described_class, application_form: application_form)

        application_form.application_work_experiences.each do |work|
          expect(result.text).to include(work.role)
          expect(result.text).to include(work.start_date.to_s(:month_and_year))
          if work.working_with_children
            expect(result.text).to include(t('application_form.review.role_involved_working_with_children'))
          end
        end
      end

      it 'renders correct text for "Change" links in each attribute row' do
        result = render_inline(described_class, application_form: application_form)

        change_job_title = result.css('.govuk-summary-list__actions')[0].text.strip
        change_type = result.css('.govuk-summary-list__actions')[1].text.strip
        change_description = result.css('.govuk-summary-list__actions')[2].text.strip
        change_dates = result.css('.govuk-summary-list__actions')[3].text.strip

        expect(change_job_title).to eq(
          'Change job title for Teaching Assistant, Vararu School, January 2019 to June 2019',
        )
        expect(change_type).to eq(
          'Change type for Teaching Assistant, Vararu School, January 2019 to June 2019',
        )
        expect(change_description).to eq(
          'Change description for Teaching Assistant, Vararu School, January 2019 to June 2019',
        )
        expect(change_dates).to eq(
          'Change dates for Teaching Assistant, Vararu School, January 2019 to June 2019',
        )
      end

      it 'appends dates to "Change" links if same role at same organisation' do
        result = render_inline(described_class, application_form: application_form)

        change_job_title_for_same1 = result.css('.govuk-summary-list__actions')[0].text.strip
        change_job_title_for_unique = result.css('.govuk-summary-list__actions')[4].text.strip
        change_job_title_for_same2 = result.css('.govuk-summary-list__actions')[8].text.strip

        expect(change_job_title_for_same1).to eq(
          'Change job title for Teaching Assistant, Vararu School, January 2019 to June 2019',
        )
        expect(change_job_title_for_unique).to eq(
          'Change job title for Teaching Assistant, Theo School',
        )
        expect(change_job_title_for_same2).to eq(
          'Change job title for Teaching Assistant, Vararu School, August 2019 to October 2019',
        )
      end
    end

    context 'when jobs are not editable' do
      it 'renders component without an edit link' do
        result = render_inline(described_class, application_form: application_form, editable: false)

        expect(result.css('.app-summary-list__actions').text).not_to include('Change')
        expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.volunteering.delete'))
      end
    end
  end

  context 'when there are breaks in the work history' do
    let(:application_form) do
      Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
        create(:application_form) do |form|
          data[:start_date] = Time.zone.local(2019, 8, 1)
          data[:end_date] = Time.zone.local(2019, 9, 1)
          form.application_work_experiences.create(data)

          form.work_history_breaks = 'WE WERE ON A BREAK!'
        end
      end
    end

    context 'when work history breaks are editable' do
      it 'renders summary card for breaks in the work history' do
        Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
          result = render_inline(described_class, application_form: application_form)

          expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.work_history.break.label'))
          expect(result.css('.govuk-summary-list__value').to_html).to include('WE WERE ON A BREAK!')
          expect(result.css('.govuk-summary-list__actions a')[4].attr('href')).to include(
            Rails.application.routes.url_helpers.candidate_interface_work_history_breaks_path,
          )
          expect(result.css('.govuk-summary-list__actions').text).to include(t('application_form.work_history.break.change_label'))
        end
      end
    end

    context 'when work history breaks are not editable' do
      it 'renders component without an edit link' do
        Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
          result = render_inline(described_class, application_form: application_form, editable: false)

          expect(result.css('.govuk-summary-list__actions').text).not_to include(t('application_form.work_history.break.enter_label'))
        end
      end
    end
  end

  context 'when no work experience' do
    let(:application_form) do
      create(:application_form, work_history_explanation: 'I no work.')
    end

    context 'when no work experience explanantion is editable' do
      it 'renders component asking for an explanation' do
        result = render_inline(described_class, application_form: application_form)

        expect(result.css('.govuk-summary-list__key').text).to include('Explanation of why you’ve been out of the workplace')
        expect(result.css('.govuk-summary-list__value').to_html).to include('I no work.')
        expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
          Rails.application.routes.url_helpers.candidate_interface_work_history_explanation_path,
        )
        expect(result.css('.govuk-summary-list__actions').text).to include('Change explanation of why you’ve been out of the workplace')
      end
    end

    context 'when no work experience explanantion is not editable' do
      it 'renders component asking for an explanation' do
        result = render_inline(described_class, application_form: application_form, editable: false)

        expect(result.css('.govuk-summary-list__actions').text).not_to include('Change explanation')
      end
    end
  end
end
