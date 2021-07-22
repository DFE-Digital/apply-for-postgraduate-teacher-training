require 'rails_helper'

RSpec.describe CandidateInterface::DegreeYearForm, type: :model do
  describe 'award year' do
    context 'year validations' do
      let(:model) do
        described_class.new(award_year: award_year)
      end

      include_examples 'year validations', :award_year
    end

    it 'is invalid if the award year is more than one year into the future' do
      Timecop.freeze(Time.zone.local(2008, 1, 1)) do
        degree_form = described_class.new(award_year: '2010')

        degree_form.validate(:award_year)

        expect(degree_form.errors.full_messages_for(:award_year)).to eq(
          ['Award year Enter a year before 2010'],
        )
      end
    end

    it 'is invalid if the degree is incomplete and the award year is in the past' do
      Timecop.freeze(Time.zone.local(2008, 1, 1)) do
        degree_form = described_class.new(award_year: '1990')

        degree_form.validate(:award_year)

        expect(degree_form.errors.full_messages_for(:award_year)).to eq(
          ['Award year Enter a year in the future'],
        )
      end
    end
  end

  describe 'start year' do
    it 'is invalid if greater than the award year' do
      degree_form = described_class.new(start_year: '2009', award_year: '2008')
      error_message = t('activemodel.errors.models.candidate_interface/degree_year_form.attributes.start_year.greater_than_award_year')

      degree_form.validate(:start_year)

      expect(degree_form.errors.full_messages_for(:start_year)).to eq(
        ["Start year #{error_message}"],
      )
    end
  end
end
