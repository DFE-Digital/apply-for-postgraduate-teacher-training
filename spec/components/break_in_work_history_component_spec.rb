require 'rails_helper'

RSpec.describe BreakInWorkHistoryComponent do
  let(:january2018) { Time.zone.local(2018, 1, 1) }
  let(:february2019) { Time.zone.local(2019, 2, 1) }
  let(:april2019) { Time.zone.local(2019, 4, 1) }
  let(:work_break) do
    build_stubbed(
      :application_work_history_break,
      start_date: february2019,
      end_date: april2019,
      reason: 'I fell asleep.',
    )
  end

  context 'when work history break is less than 12 months' do
    it 'renders the component with the break in months, reason and dates' do
      result = render_inline(BreakInWorkHistoryComponent.new(work_break: work_break))

      expect(result.text).to include('Break in work history (1 month)')
      expect(result.text).to include('I fell asleep.')
      expect(result.text).to include('February 2019 - April 2019')
    end
  end

  context 'when work history break is more than 12 months' do
    it 'renders the component with the break in months' do
      work_break = build_stubbed(
        :application_work_history_break,
        start_date: january2018,
        end_date: april2019,
        reason: 'I fell asleep.',
      )
      result = render_inline(BreakInWorkHistoryComponent.new(work_break: work_break))

      expect(result.text).to include('Break in work history (1 year and 2 months)')
    end
  end

  context 'when editable' do
    it 'renders the component with a delete link' do
      result = render_inline(BreakInWorkHistoryComponent.new(work_break: work_break, editable: true))

      expect(result.text).to include('Delete entry for break between February 2019 and April 2019')
    end

    it 'renders the component with change links' do
      result = render_inline(BreakInWorkHistoryComponent.new(work_break: work_break, editable: true))

      expect(result.text).to include('Change description for break between February 2019 and April 2019')
      expect(result.text).to include('Change dates for break between February 2019 and April 2019')
    end
  end

  context 'when not editable' do
    it 'renders the component without a delete link' do
      result = render_inline(BreakInWorkHistoryComponent.new(work_break: work_break, editable: false))

      expect(result.text).not_to include('Delete entry for break between February 2019 and April 2019')
    end

    it 'renders the component without change links' do
      result = render_inline(BreakInWorkHistoryComponent.new(work_break: work_break, editable: false))

      expect(result.text).not_to include('Change description for break between February 2019 and April 2019')
      expect(result.text).not_to include('Change dates for break between February 2019 and April 2019')
    end
  end
end
