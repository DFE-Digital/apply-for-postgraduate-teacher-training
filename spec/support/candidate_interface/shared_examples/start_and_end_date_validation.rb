RSpec.shared_examples 'validation for a start and end date' do |error_scope|
  describe 'start date' do
    it 'is invalid if not well-formed' do
      form = described_class.new(start_date_month: '99', start_date_year: '99')

      form.validate

      expect(form.errors.full_messages_for(:start_date)).to eq(
        ["Start date #{t("activemodel.errors.models.candidate_interface/#{error_scope}.attributes.start_date.invalid")}"],
      )
    end

    it 'is invalid if the date is after the end date' do
      form = described_class.new(
        start_date_month: '5', start_date_year: '2018',
        end_date_month: '5', end_date_year: '2017'
      )

      form.validate

      expect(form.errors.full_messages_for(:start_date)).to eq(
        ["Start date #{t("activemodel.errors.models.candidate_interface/#{error_scope}.attributes.start_date.before")}"],
      )
    end

    it 'is valid if the date is equal to the end date' do
      form = described_class.new(
        start_date_month: '5', start_date_year: '2018',
        end_date_month: '5', end_date_year: '2018'
      )

      form.validate

      expect(form.errors.full_messages_for(:start_date)).to be_empty
    end
  end

  describe 'end date' do
    it 'is valid if left completely blank' do
      form = described_class.new(end_date_month: '', end_date_year: '')

      form.validate

      expect(form.errors.full_messages_for(:end_date)).to be_empty
    end

    it 'is invalid if month left blank' do
      form = described_class.new(end_date_month: '', end_date_year: '2019')

      form.validate

      expect(form.errors.full_messages_for(:end_date)).to eq(
        ["End date #{t("activemodel.errors.models.candidate_interface/#{error_scope}.attributes.end_date.invalid")}"],
      )
    end

    it 'is invalid if year left blank' do
      form = described_class.new(end_date_month: '5', end_date_year: '')

      form.validate

      expect(form.errors.full_messages_for(:end_date)).to eq(
        ["End date #{t("activemodel.errors.models.candidate_interface/#{error_scope}.attributes.end_date.invalid")}"],
      )
    end

    it 'is invalid if not well-formed' do
      form = described_class.new(end_date_month: '99', end_date_year: '2019')

      form.validate

      expect(form.errors.full_messages_for(:end_date)).to eq(
        ["End date #{t("activemodel.errors.models.candidate_interface/#{error_scope}.attributes.end_date.invalid")}"],
      )
    end

    it 'is invalid if year is beyond the current year' do
      Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
        form = described_class.new(end_date_month: '1', end_date_year: '2029')

        form.validate

        expect(form.errors.full_messages_for(:end_date)).to eq(
          ["End date #{t("activemodel.errors.models.candidate_interface/#{error_scope}.attributes.end_date.in_the_future")}"],
        )
      end
    end

    it 'is invalid if year is the current year but month is after the current month' do
      Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
        form = described_class.new(end_date_month: '11', end_date_year: '2019')

        form.validate

        expect(form.errors.full_messages_for(:end_date)).to eq(
          ["End date #{t("activemodel.errors.models.candidate_interface/#{error_scope}.attributes.end_date.in_the_future")}"],
        )
      end
    end

    it 'is valid if year and month are before the current year and month' do
      Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
        form = described_class.new(end_date_month: '9', end_date_year: '2019')

        form.validate

        expect(form.errors.full_messages_for(:end_date)).to be_empty
      end
    end
  end
end
