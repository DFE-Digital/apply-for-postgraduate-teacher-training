require 'rails_helper'

RSpec.describe ApplicationDates, type: :model do
  let(:submitted_at) { Time.zone.local(2019, 5, 1, 12, 0, 0).end_of_day }

  let(:application_form) do
    create(:completed_application_form, :without_application_choices, submitted_at: submitted_at)
  end

  let!(:application_choice) do
    create(:application_choice, edit_by: submitted_at + 5.days, application_form: application_form)
  end

  subject(:application_dates) do
    described_class.new(application_form)
  end

  describe '#submitted_at' do
    it 'returns date that application was submitted on' do
      expect(application_dates.submitted_at).to eql(submitted_at)
    end
  end

  describe '#reject_by_default_at' do
    it 'return nil when the reject_by_default_at is not set' do
      expect(application_dates.reject_by_default_at).to be_nil
    end

    it 'returns date that providers will respond by when reject_by_default_at is set' do
      reject_by_default_at = Time.zone.local(2019, 6, 28, 23, 59, 59)
      application_form.application_choices.each do |application_choice|
        application_choice.update(reject_by_default_at: reject_by_default_at)
      end
      expect(application_dates.reject_by_default_at).to eql reject_by_default_at
    end
  end

  describe '#edit_by' do
    it 'returns date that the candidate can edit by' do
      expect(application_dates.edit_by).to be_within(1.second).of(application_choice.edit_by)
    end
  end

  describe '#days_remaining_to_edit' do
    it 'returns number of days remaining that a candidate can edit by' do
      Timecop.travel(submitted_at) do
        expect(application_dates.days_remaining_to_edit).to eq(4)
      end

      Timecop.travel(submitted_at + 3.days) do
        expect(application_dates.days_remaining_to_edit).to eq(1)
      end
    end
  end

  describe '#declined_by_default_at' do
    let(:choices) { application_form.application_choices }

    it 'returns correct declined_by_default_at' do
      choices.update_all(status: :offer, decline_by_default_at: 10.business_days.after(submitted_at))

      expect(application_dates.decline_by_default_at).to eq(10.business_days.after(submitted_at))
    end
  end

  describe '#form_open_to_editing?' do
    it 'returns true if the form is still open to editing' do
      Timecop.travel(submitted_at) do
        expect(application_dates).to be_form_open_to_editing
      end
    end

    it 'returns false if the form is closed to editing' do
      Timecop.travel(submitted_at + 11.days) do
        expect(application_dates).not_to be_form_open_to_editing
      end
    end
  end
end
