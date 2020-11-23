require 'rails_helper'

RSpec.describe CandidateInterface::OtherQualificationWizard, type: :model do
  let(:error_message_scope) do
    'activemodel.errors.models.candidate_interface/other_qualification_wizard.attributes.'
  end

  describe 'validations' do
    # it { is_expected.to validate_presence_of(:qualification_type) }
    it { is_expected.to validate_presence_of(:award_year).on(:details) }
    # it { is_expected.to validate_length_of(:qualification_type).is_at_most(255) }
    it { is_expected.to validate_length_of(:subject).is_at_most(255).on(:details) }
    it { is_expected.to validate_length_of(:grade).is_at_most(255).on(:details) }

    describe 'subject' do
      it 'validates presence except for non-uk and other qualifications' do
        non_uk_qualification = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'non_uk', subject: nil)
        other_uk_qualification = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'Other', subject: nil)
        gcse = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'GCSE', subject: nil)

        non_uk_qualification.valid?(:details)
        other_uk_qualification.valid?(:details)
        gcse.valid?(:details)

        expect(non_uk_qualification.errors.full_messages_for(:subject)).to be_empty
        expect(other_uk_qualification.errors.full_messages_for(:subject)).to be_empty
        expect(gcse.errors.full_messages_for(:subject)).not_to be_empty
      end
    end

    describe 'grade' do
      it 'validates presence except for non-uk and other qualifications' do
        non_uk_qualification = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'non_uk', grade: nil)
        other_uk_qualification = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'Other', grade: nil)
        gcse = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'GCSE', grade: nil)

        non_uk_qualification.valid?(:details)
        other_uk_qualification.valid?(:details)
        gcse.valid?(:details)

        expect(non_uk_qualification.errors.full_messages_for(:grade)).to be_empty
        expect(other_uk_qualification.errors.full_messages_for(:grade)).to be_empty
        expect(gcse.errors.full_messages_for(:grade)).not_to be_empty
      end

      it 'validates grade format for A/AS levels, sanitizing the string in the process' do
        valid_a_level = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'A level', grade: 'a* a*')
        valid_as_level = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'AS level', grade: 'b  b')
        valid_other_qualification = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'Other', grade: 'Gold star')
        invalid_a_level = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'A level', grade: 'a* a* b')
        invalid_as_level = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'AS level', grade: '85%')

        [valid_a_level, valid_as_level, invalid_a_level, invalid_as_level, valid_other_qualification].each { |q| q.valid?(:details) }

        expect(valid_a_level.errors.messages[:grade]).to be_blank
        expect(valid_a_level.grade).to eq 'A*A*'
        expect(valid_as_level.errors.messages[:grade]).to be_blank
        expect(valid_as_level.grade).to eq 'BB'
        expect(valid_other_qualification.errors.messages[:grade]).to be_blank
        expect(valid_other_qualification.grade).to eq 'Gold star'

        expect(invalid_a_level.errors.messages[:grade].pop).to eq 'Enter a real grade'
        expect(invalid_as_level.errors.messages[:grade].pop).to eq 'Enter a real grade'
      end

      it 'validates grade format for GCSE, sanitizing the string in the process' do
        valid_gcse_one = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'GCSE', grade: '9 - 8')
        valid_gcse_two = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'GCSE', grade: 'e   e')
        valid_other_qualification = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'Other', grade: 'Gold star')
        invalid_gcse = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'GCSE', grade: '5%')

        [valid_gcse_one, valid_gcse_two, valid_other_qualification, invalid_gcse].each { |q| q.valid?(:details) }

        expect(valid_gcse_one.errors.messages[:grade]).to be_blank
        expect(valid_gcse_one.grade).to eq '9-8'
        expect(valid_gcse_two.errors.messages[:grade]).to be_blank
        expect(valid_gcse_two.grade).to eq 'EE'
        expect(valid_other_qualification.errors.messages[:grade]).to be_blank
        expect(valid_other_qualification.grade).to eq 'Gold star'

        expect(invalid_gcse.errors.messages[:grade].pop).to eq 'Enter a real grade'
      end
    end

    it { is_expected.to validate_presence_of(:subject).on(:details) }
    it { is_expected.to validate_presence_of(:grade).on(:details) }

    describe 'institution country' do
      context 'when it is a non-uk qualification' do
        it 'validates for presence and inclusion in the COUNTY_NAMES constant' do
          valid_qualification = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'non_uk', institution_country: 'GB')
          blank_country_qualification = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'non_uk')
          inavlid_country_qualification = CandidateInterface::OtherQualificationWizard.new(nil, nil, qualification_type: 'non_uk', institution_country: 'QQ')

          valid_qualification.valid?(:details)
          blank_country_qualification.valid?(:details)
          inavlid_country_qualification.valid?(:details)

          expect(valid_qualification.errors.full_messages_for(:institution_country)).to be_empty
          expect(blank_country_qualification.errors.full_messages_for(:institution_country)).not_to be_empty
          expect(inavlid_country_qualification.errors.full_messages_for(:institution_country)).not_to be_empty
        end
      end
    end

    describe 'award year' do
      it 'is valid if the award year is 4 digits' do
        qualification = CandidateInterface::OtherQualificationWizard.new(nil, nil, award_year: '2009')

        qualification.valid?(:details)

        expect(qualification.errors.full_messages_for(:award_year)).to be_empty
      end

      ['a year', '200'].each do |invalid_date|
        it "is invalid if the award year is '#{invalid_date}'" do
          qualification = CandidateInterface::OtherQualificationWizard.new(nil, nil, award_year: invalid_date)
          error_message = t('award_year.invalid', scope: error_message_scope)

          qualification.valid?(:details)

          expect(qualification.errors.full_messages_for(:award_year)).to eq(
            ["Award year #{error_message}"],
          )
        end
      end

      it 'is invalid if the award year is in the future' do
        Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
          qualification = CandidateInterface::OtherQualificationWizard.new(nil, nil, award_year: '2029')

          qualification.valid?(:details)

          expect(qualification.errors.full_messages_for(:award_year)).to eq(
            ['Award year Assessment year must be this year or a previous year'],
          )
        end
      end
    end
  end

  describe '.build_all_from_application' do
    let(:application_form) do
      create(:application_form) do |form|
        form.application_qualifications.create(
          level: 'other',
          created_at: Time.zone.local(2019, 1, 1, 1, 9, 0, 0),
        )
        form.application_qualifications.create(
          level: 'other',
          qualification_type: 'BTEC',
          subject: 'Being a Superhero',
          grade: 'Distinction',
          predicted_grade: false,
          award_year: '2012',
          created_at: Time.zone.local(2019, 1, 1, 21, 0, 0),
        )
        form.application_qualifications.create(level: 'degree')
        form.application_qualifications.create(level: 'gcse')
      end
    end

    it 'creates an array of objects based on the provided ApplicationForm' do
      qualifications = CandidateInterface::OtherQualificationWizard.build_all_from_application(application_form)

      expect(qualifications).to include(
        have_attributes(
          qualification_type: 'BTEC',
          subject: 'Being a Superhero',
          grade: 'Distinction',
          award_year: '2012',
        ),
      )
    end

    it 'only includes other qualifications and not degrees or GCSEs' do
      qualifications = CandidateInterface::OtherQualificationWizard.build_all_from_application(application_form)

      expect(qualifications.count).to eq(2)
    end

    it 'orders other qualifications by created at' do
      qualifications = CandidateInterface::OtherQualificationWizard.build_all_from_application(application_form)

      expect(qualifications.last).to have_attributes(
        qualification_type: 'BTEC',
        subject: 'Being a Superhero',
      )
    end
  end

  describe '.build_from_qualification' do
    it 'returns a new OtherQualificationWizard object using an application qualification' do
      application_qualification = build_stubbed(
        :application_qualification,
        level: 'other',
        qualification_type: 'BTEC',
        subject: 'Being a Sidekick',
        grade: 'Merit',
        predicted_grade: false,
        award_year: '2010',
      )

      qualification = CandidateInterface::OtherQualificationWizard.build_from_qualification(application_qualification)

      expect(qualification).to have_attributes(qualification_type: 'BTEC', subject: 'Being a Sidekick')
    end
  end

  describe '#title' do
    context 'for a non-uk qualification' do
      it 'concatenates the non_uk_qualification_type and subject' do
        qualification = CandidateInterface::OtherQualificationWizard.new(
          nil,
          nil,
          qualification_type: 'non_uk',
          non_uk_qualification_type: 'Master Craftsman',
          subject: 'Igloo Building 101',
        )

        expect(qualification.title).to eq('Master Craftsman Igloo Building 101')
      end
    end

    context 'for an other uk qualification' do
      it 'concatenates the other_uk_qualification_type and subject' do
        qualification = CandidateInterface::OtherQualificationWizard.new(
          nil,
          nil,
          qualification_type: 'Other',
          other_uk_qualification_type: 'Master Craftsman',
          subject: 'Chopping Trees 1-0-done',
        )

        expect(qualification.title).to eq('Master Craftsman Chopping Trees 1-0-done')
      end
    end

    context 'for other uk qualificaitons and GCSEs and A-levels' do
      it 'concatenates the qualification type and subject' do
        qualification = CandidateInterface::OtherQualificationWizard.new(
          nil,
          nil,
          qualification_type: 'BTEC',
          subject: 'Being a Supervillain',
        )

        expect(qualification.title).to eq('BTEC Being a Supervillain')
      end
    end
  end

  describe '#qualification_type_name' do
    context 'for a non-uk qualification' do
      it 'returns the non_uk_qualification_type' do
        qualification = CandidateInterface::OtherQualificationWizard.new(
          nil,
          nil,
          qualification_type: 'non_uk',
          non_uk_qualification_type: 'Master Craftsman',
        )

        expect(qualification.qualification_type_name).to eq('Master Craftsman')
      end
    end

    context 'for an other uk qualification with the qualification type Other' do
      it 'returns the other_uk_qualification_type' do
        qualification = CandidateInterface::OtherQualificationWizard.new(
          nil,
          nil,
          qualification_type: 'Other',
          other_uk_qualification_type: 'Master Craftsman',
        )

        expect(qualification.qualification_type_name).to eq('Master Craftsman')
      end
    end

    context 'for other uk qualificaitons and GCSEs and A-levels' do
      it 'returns the qualification type' do
        qualification = CandidateInterface::OtherQualificationWizard.new(
          nil,
          nil,
          qualification_type: 'BTEC',
        )

        expect(qualification.qualification_type_name).to eq('BTEC')
      end
    end
  end

  describe '#next_step' do
    it 'returns `check` if `checking_answers` option is given and current step is `type`' do
      qualification = CandidateInterface::OtherQualificationWizard.new(
        nil,
        nil,
        current_step: :type,
        checking_answers: true,
      )

      expect(qualification.next_step).to eq [:check]
    end

    it 'returns `details` if `checking_answers` option is not given and current step is `type`' do
      qualification = CandidateInterface::OtherQualificationWizard.new(
        nil,
        nil,
        current_step: :type,
      )

      expect(qualification.next_step).to eq [:details]
    end

    it 'returns `details` if `checking_answers` option is given and current step is `type` and `qualification_type` has changed' do
      application_qualification = create :other_qualification, qualification_type: 'Other'

      qualification = CandidateInterface::OtherQualificationWizard.new(
        nil,
        nil,
        id: application_qualification.id,
        current_step: :type,
        checking_answers: true,
        qualification_type: 'A level',
      )

      expect(qualification.next_step).to eq [:details]
    end

    it 'returns `check` if `checking_answers` option is given and current step is `type` and `qualification_type` has not changed' do
      application_qualification = create :other_qualification, qualification_type: 'Other'

      qualification = CandidateInterface::OtherQualificationWizard.new(
        nil,
        nil,
        id: application_qualification.id,
        current_step: :type,
        checking_answers: true,
        qualification_type: 'Other',
      )

      expect(qualification.next_step).to eq [:check]
    end

    it 'returns `check` if current_step is `details`' do
      qualification = CandidateInterface::OtherQualificationWizard.new(
        nil,
        nil,
        current_step: :details,
      )

      expect(qualification.next_step).to eq [:check]
    end
  end

  describe '#previous_step' do
    it 'returns `type` if current_step is `details`' do
      qualification = CandidateInterface::OtherQualificationWizard.new(
        nil,
        nil,
        current_step: :details,
      )

      expect(qualification.previous_step).to eq [:type]
    end

    it 'returns `details` if current_step is `check`' do
      qualification = CandidateInterface::OtherQualificationWizard.new(
        nil,
        nil,
        current_step: :check,
      )

      expect(qualification.previous_step).to eq [:details]
    end

    it 'returns `check` if current_step is `details` and checking_answers option is given' do
      qualification = CandidateInterface::OtherQualificationWizard.new(
        nil,
        nil,
        current_step: :details,
        checking_answers: true,
      )

      expect(qualification.previous_step).to eq [:check]
    end
  end

  describe '#missing_type_validation_error?' do
    it 'returns true if `qualification_type` is missing' do
      qualification = CandidateInterface::OtherQualificationWizard.new(
        nil,
        nil,
        current_step: :details,
      )
      expect(qualification.valid?(:type)).to be false
      expect(qualification.missing_type_validation_error?).to be true
    end

    it 'returns false if `qualification_type` is missing' do
      qualification = CandidateInterface::OtherQualificationWizard.new(
        nil,
        nil,
        current_step: :details,
        qualification_type: 'A level',
      )
      expect(qualification.valid?(:type)).to be true
      expect(qualification.missing_type_validation_error?).to be false
    end
  end

  describe '#grade_hint' do
    it 'returns a GCSE hint if qualification_type is GCSE_TYPE' do
      qualification = CandidateInterface::OtherQualificationWizard.new(
        nil,
        nil,
        current_step: :details,
        qualification_type: 'GCSE',
      )

      expect(qualification.grade_hint).to eq({ text: 'For example, ‘C’, ‘CD’, ‘4’ or ‘4-3’' })
    end

    it 'returns nil for any other qualification_type' do
      namespace = CandidateInterface::OtherQualificationWizard

      (namespace::ALL_VALID_TYPES - [namespace::GCSE_TYPE]).each do |qualification_type|
        qualification = CandidateInterface::OtherQualificationWizard.new(
          nil,
          nil,
          current_step: :details,
          qualification_type: qualification_type,
        )

        expect(qualification.grade_hint).to eq nil
      end
    end
  end
end
