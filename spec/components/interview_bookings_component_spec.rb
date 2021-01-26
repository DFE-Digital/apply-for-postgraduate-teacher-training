require 'rails_helper'

RSpec.describe InterviewBookingsComponent, type: :component do
  let(:interview) do
    create(
      :interview,
      date_and_time: Time.zone.local(2020, 6, 6, 18, 30),
    )
  end

  it 'renders the interview time' do
    result = render_inline(described_class.new(interview.application_choice))
    expect(result.text).to include('6 June 2020 at 6:30pm')
  end

  it 'renders the provider name' do
    result = render_inline(described_class.new(interview.application_choice))
    expect(result.text).to include(interview.provider.name)
  end

  it 'renders the location, with breaks and hyperlinks' do
    interview.update!(
      location: "123\nTest Street\nLondon\nCheck this if you get lost https://www.googlemaps.com",
    )
    result = render_inline(described_class.new(interview.application_choice))
    expected_markup = <<-HTML
      <p class="govuk-body">123
      <br>Test Street
      <br>London
      <br>Check this if you get lost <a href="https://www.googlemaps.com">https://www.googlemaps.com</a></p>
    HTML

    expect(result.to_html.squish).to include(expected_markup.squish)
  end

  it 'renders additional details, with breaks and hyperlinks' do
    interview.update!(
      additional_details: "Backup Zoom call if the trains are cancelled \n https://us02web.zoom.us/j/foo",
    )
    result = render_inline(described_class.new(interview.application_choice))
    expected_markup = <<-HTML
      <p class="govuk-body">Backup Zoom call if the trains are cancelled
      <br> <a href="https://us02web.zoom.us/j/foo">https://us02web.zoom.us/j/foo</a></p>
    HTML

    expect(result.to_html.squish).to include(expected_markup.squish)
  end

  context 'when location contains undesireable HTML tags' do
    it 'removes them' do
      interview.update!(
        location: "l33t hax <script>alert('pwned')</script>",
      )
      result = render_inline(described_class.new(interview.application_choice))

      expect(result.to_html).to include 'l33t hax'
      expect(result.to_html).not_to include 'script'
    end
  end

  context 'when additional details contains undesireable HTML tags' do
    it 'removes them' do
      interview.update!(
        additional_details: "l33t hax <script>alert('pwned')</script>",
      )
      result = render_inline(described_class.new(interview.application_choice))

      expect(result.to_html).to include 'l33t hax'
      expect(result.to_html).not_to include 'script'
    end
  end

  context 'when there is more than one interview for the application choice' do
    before { interview.update!(additional_details: 'This is interview 1') }

    let!(:additional_interview) do
      create(
        :interview,
        additional_details: 'This is interview 2',
        application_choice: interview.application_choice,
      )
    end

    it 'renders them in a numbered list' do
      result = render_inline(described_class.new(interview.application_choice))

      expect(result.to_html).to include '<ul class="govuk-list govuk-list--number">'
      expect(result.text).to include 'This is interview 1'
      expect(result.text).to include 'This is interview 2'
    end
  end
end
