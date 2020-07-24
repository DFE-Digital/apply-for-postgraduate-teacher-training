require 'rails_helper'

RSpec.describe CandidateInterface::ChooseEflReviewComponent do
  describe '.call' do
    context 'when english_proficiency has an IELTS qualification' do
      let(:english_proficiency) { build(:english_proficiency, :with_ielts_qualification) }

      it 'returns an instance of IeltsReviewComponent' do
        component = described_class.call(english_proficiency)

        expect(component).to be_instance_of(CandidateInterface::EnglishForeignLanguage::IeltsReviewComponent)
        expect(component.ielts_qualification).to eq english_proficiency.efl_qualification
      end
    end

    context 'when english_proficiency has a TOEFL qualification' do
      let(:english_proficiency) { build(:english_proficiency, :with_toefl_qualification) }

      it 'returns an instance of ToeflReviewComponent' do
        component = described_class.call(english_proficiency)

        expect(component).to be_instance_of(CandidateInterface::EnglishForeignLanguage::ToeflReviewComponent)
        expect(component.toefl_qualification).to eq english_proficiency.efl_qualification
      end
    end

    context 'when english_proficiency has an Other EFL qualification' do
      let(:english_proficiency) { build(:english_proficiency, :with_other_qualification) }

      it 'returns an instance of OtherEflQualificationReviewComponent' do
        component = described_class.call(english_proficiency)

        expect(component).to be_instance_of(CandidateInterface::EnglishForeignLanguage::OtherEflQualificationReviewComponent)
        expect(component.other_qualification).to eq english_proficiency.efl_qualification
      end
    end

    context 'when english_proficiency does not have a qualification' do
      let(:english_proficiency) { build(:english_proficiency, :no_qualification) }

      it 'returns an instance of NoEflQualificationReviewComponent' do
        component = described_class.call(english_proficiency)

        expect(component).to be_instance_of(CandidateInterface::EnglishForeignLanguage::NoEflQualificationReviewComponent)
        expect(component.english_proficiency).to eq english_proficiency
      end
    end
  end
end
