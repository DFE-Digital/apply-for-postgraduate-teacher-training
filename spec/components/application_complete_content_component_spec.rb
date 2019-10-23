require 'rails_helper'

RSpec.describe ApplicationCompleteContentComponent do
  let(:submitted_at) { Time.new(2019, 10, 22) }

  def render_result
    render_inline(ApplicationCompleteContentComponent, submitted_at: submitted_at)
  end

  it 'renders with correct submission date' do
    expect(render_result.text).to include('22 October 2019')
  end

  it 'renders with correct respond by date' do
    expect(render_result.text).to include('1 December 2019')
  end

  it 'renders with correct edit by date' do
    expect(render_result.text).to include('29 October 2019')
  end

  it 'renders with correct days remaining after time has passed' do
    Timecop.travel(submitted_at) do
      expect(render_result.text).to include('7 days')
    end

    Timecop.travel(submitted_at + 2.days) do
      expect(render_result.text).to include('5 days')
    end

    Timecop.travel(submitted_at + 6.days) do
      expect(render_result.text).to include('1 day')
    end
  end

  it 'renders without edit content after lots of time has passed' do
    Timecop.travel(submitted_at + 7.days) do
      expect(render_result.text).not_to include('Edit your application')
    end
  end
end
