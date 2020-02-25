require 'rails_helper'

RSpec.describe CandidateInterface::EqualityAndDiversity::SexForm, type: :model do
  describe '#build_from_application' do
    it 'creates an object based on the application form' do
      application_form = build_stubbed(:application_form, equality_and_diversity: { 'sex' => 'male' })
      form = CandidateInterface::EqualityAndDiversity::SexForm.build_from_application(application_form)

      expect(form.sex).to eq('male')
    end

    it 'returns nil if equality and diversity is nil' do
      application_form = build_stubbed(:application_form, equality_and_diversity: nil)
      form = CandidateInterface::EqualityAndDiversity::SexForm.build_from_application(application_form)

      expect(form.sex).to eq(nil)
    end
  end

  describe '#save' do
    let(:application_form) { create(:application_form) }

    context 'when sex is blank' do
      it 'returns false' do
        form = CandidateInterface::EqualityAndDiversity::SexForm.new

        expect(form.save(application_form)).to be(false)
      end
    end

    context 'when sex has a value' do
      it 'returns true' do
        form = CandidateInterface::EqualityAndDiversity::SexForm.new(sex: 'male')

        expect(form.save(application_form)).to be(true)
      end

      it 'updates the equality and diversity information on the application form' do
        form = CandidateInterface::EqualityAndDiversity::SexForm.new(sex: 'male')
        form.save(application_form)

        expect(application_form.equality_and_diversity).to eq('sex' => 'male')
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:sex) }
  end
end
