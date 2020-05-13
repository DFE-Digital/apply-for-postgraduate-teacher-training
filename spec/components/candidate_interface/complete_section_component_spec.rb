require 'rails_helper'

RSpec.describe CandidateInterface::CompleteSectionComponent do
  let(:application_form) { create(:application_form) }
  let(:path) { Rails.application.routes.url_helpers.candidate_interface_application_form_path }
  let(:field_name) { 'field_name' }

  it 'renders successfully' do
    result = render_inline(
      described_class.new(application_form: application_form,
                          path: path,
                          field_name: field_name),
    )

    expect(result.css('.govuk-form-group').text).to include 'I have completed this section'
    expect(result.to_html).to include path
    expect(result.to_html).to include field_name
  end
end
