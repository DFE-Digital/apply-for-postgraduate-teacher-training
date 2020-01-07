require 'rails_helper'

RSpec.describe CandidateInterface::RefereesReviewComponent do
  let(:application_form) do
    create(:completed_application_form, references_count: 2)
  end

  context 'when referees are editable' do
    let(:application_form) { create(:completed_application_form, references_count: 2) }

    it "renders component with correct values for a referee's name" do
      first_referee = application_form.application_references.first
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.app-summary-card__title').text).to include('First referee')
      expect(result.css('.govuk-summary-list__key').text).to include('Name')
      expect(result.css('.govuk-summary-list__value').to_html).to include(first_referee.name)
    end

    it "renders component with correct values for a referee's email address" do
      first_referee = application_form.application_references.first
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.govuk-summary-list__key').text).to include('Email address')
      expect(result.css('.govuk-summary-list__value').to_html).to include(first_referee.email_address)
    end

    it 'renders component along with a delete link for each referee' do
      referee_id = application_form.application_references.first.id
      result = render_inline(described_class, application_form: application_form)

      expect(result.css('.app-summary-card__actions').text).to include(t('application_form.referees.delete'))
      expect(result.css('.app-summary-card__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_confirm_destroy_referee_path(referee_id),
      )
    end

    it 'renders component with an id for name row' do
      referee_id = application_form.application_references.first.id
      result = render_inline(described_class, application_form: application_form)

      name_row_value = result.css('.govuk-summary-list__value')[0]

      expect(name_row_value.attr('id')).to include("referees-#{referee_id}-name")
    end

    it 'renders component with aria-describedby for each attribute row' do
      referee_id = application_form.application_references.first.id
      result = render_inline(described_class, application_form: application_form)

      change_links = [
        result.css('.govuk-summary-list__actions a')[0],
        result.css('.govuk-summary-list__actions a')[1],
        result.css('.govuk-summary-list__actions a')[2],
      ]

      change_links.each do |change_link|
        expect(change_link.attr('aria-describedby')).to include("referees-#{referee_id}-name")
      end
    end
  end

  context 'when referees are not editable' do
    let(:application_form) { create(:completed_application_form, references_count: 1) }

    it 'renders component without an edit link' do
      result = render_inline(described_class, application_form: application_form, editable: false)

      expect(result.css('.app-summary-list__actions').text).not_to include('Change')
      expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.referees.delete'))
    end
  end

  context 'when the application has not been submitted' do
    it 'renders component with content about what happens with referee details provided' do
      application_form = build_stubbed(:application_form, submitted_at: nil)

      result = render_inline(described_class, application_form: application_form)

      expect(result.text).to include(t('application_form.referees.info.before_submission'))
    end
  end

  context 'when the application has been submitted' do
    it 'renders component with content about referees being contacted' do
      application_form = build_stubbed(:application_form, submitted_at: Time.zone.now)

      result = render_inline(described_class, application_form: application_form)

      expect(result.text).to include(t('application_form.referees.info.after_submission'))
    end
  end
end
