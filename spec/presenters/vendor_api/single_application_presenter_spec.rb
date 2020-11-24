require 'rails_helper'

# To avoid this test becoming too large, only use this spec to test complex
# logic in the presenter. For anything that is passed straight from the database
# to the API, make sure that spec/system/vendor_api/vendor_receives_application_spec.rb is updated.
RSpec.describe VendorAPI::SingleApplicationPresenter do
  describe 'attributes.withdrawal' do
    it 'returns a withdrawal object' do
      withdrawn_at = Time.zone.local(2019, 1, 1, 0, 0, 0)
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'British', second_nationality: 'American')
      application_choice = create(:application_choice, status: 'withdrawn', application_form: application_form, withdrawn_at: withdrawn_at)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:withdrawal]).to eq(reason: nil, date: withdrawn_at.iso8601)
    end
  end

  describe 'attributes.rejection' do
    it 'returns a rejection object' do
      rejected_at = Time.zone.local(2019, 1, 1, 0, 0, 0)
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'British', second_nationality: 'American')
      application_choice = create(:application_choice, status: 'rejected', application_form: application_form, rejected_at: rejected_at, rejection_reason: 'Course full')

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:rejection]).to eq(reason: 'Course full', date: rejected_at.iso8601)
    end
  end

  describe 'attributes.rejection with a withdrawn offer' do
    it 'returns a rejection object' do
      withdrawn_at = Time.zone.local(2019, 1, 1, 0, 0, 0)
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'British', second_nationality: 'American')
      application_choice = create(:application_choice, status: 'rejected', application_form: application_form, offer_withdrawn_at: withdrawn_at, offer_withdrawal_reason: 'Course full')

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:rejection]).to eq(reason: 'Course full', date: withdrawn_at.iso8601)
    end
  end

  describe 'attributes.hesa_itt_data' do
    let(:application_choice) do
      application_form = create(:completed_application_form, :with_completed_references, :with_equality_and_diversity_data)
      create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)
    end

    it 'returns the hesa_itt_data attribute of an application' do
      equality_and_diversity_data = application_choice.application_form.equality_and_diversity
      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json
      expect(response.dig(:attributes, :hesa_itt_data)).to eq(
        disability: equality_and_diversity_data['hesa_disabilities'],
        ethnicity: equality_and_diversity_data['hesa_ethnicity'],
        sex: equality_and_diversity_data['hesa_sex'],
      )
    end
  end

  describe 'attributes.work_history_break_explanation' do
    let(:february2019) { Time.zone.local(2019, 2, 1) }
    let(:april2019) { Time.zone.local(2019, 4, 1) }
    let(:september2019) { Time.zone.local(2019, 9, 1) }
    let(:december2019) { Time.zone.local(2019, 12, 1) }

    context 'when the work history breaks field has a value' do
      it 'returns the work_history_breaks attribute of an application' do
        breaks = []
        application_form = build_stubbed(
          :completed_application_form,
          :with_completed_references,
          work_history_breaks: 'I was sleeping.',
          application_work_history_breaks: breaks,
        )
        application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

        response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

        expect(response.to_json).to be_valid_against_openapi_schema('Application')
        expect(response[:attributes][:work_experience][:work_history_break_explanation]).to eq('I was sleeping.')
      end
    end

    context 'when individual breaks have been entered' do
      it 'returns a concatentation of application_work_history_breaks of an application' do
        break1 = build_stubbed(:application_work_history_break, start_date: february2019, end_date: april2019, reason: 'I was watching TV.')
        break2 = build_stubbed(:application_work_history_break, start_date: september2019, end_date: december2019, reason: 'I was playing games.')
        breaks = [break1, break2]
        application_form = build_stubbed(
          :completed_application_form,
          :with_completed_references,
          work_history_breaks: nil,
          application_work_history_breaks: breaks,
        )
        application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

        response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

        expect(response.to_json).to be_valid_against_openapi_schema('Application')
        expect(response[:attributes][:work_experience][:work_history_break_explanation]).to eq(
          "February 2019 to April 2019: I was watching TV.\n\nSeptember 2019 to December 2019: I was playing games.",
        )
      end
    end

    context 'when no breaks have been entered' do
      it 'returns an empty string' do
        breaks = []
        application_form = build_stubbed(
          :completed_application_form,
          :with_completed_references,
          work_history_breaks: nil,
          application_work_history_breaks: breaks,
        )
        application_choice = build_stubbed(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

        response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

        expect(response.to_json).to be_valid_against_openapi_schema('Application')
        expect(response[:attributes][:work_experience][:work_history_break_explanation]).to eq('')
      end
    end
  end

  describe 'attributes.candidate.nationality' do
    it 'compacts two nationalities with the same ISO value' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'Welsh', second_nationality: 'Scottish')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :nationality)).to eq %w[GB]
    end

    it 'returns nationality in the correct format' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'British', second_nationality: 'American')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:candidate][:nationality]).to eq(%w[GB US])
    end

    it 'returns sorted array of nationalties so British or Irish are first' do
      application_form = create(:completed_application_form,
                                first_nationality: 'Canadian',
                                second_nationality: 'Spanish',
                                third_nationality: 'Irish',
                                fourth_nationality: 'Welsh')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :nationality)).to eq(%w[GB IE CA ES])
    end
  end

  describe 'attributes.candidate.domicile' do
    it 'returns country code from the candidate\'s address' do
      application_form = create(:completed_application_form, :with_completed_references)
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :domicile)).to eq(application_form.country)
    end
  end

  describe 'attributes.candidate.uk_residency_status' do
    it 'returns UK Citizen if the candidates nationalties include UK' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'Irish', second_nationality: 'British')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status)).to eq('UK Citizen')
    end

    it 'returns Irish Citizen if the candidates nationalties is Irish' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'Canadian', second_nationality: 'Irish')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status)).to eq('Irish Citizen')
    end

    it 'returns details of the residency status if the candidates answered the have the right to work/study in the UK' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'Canadian',
                                                                                         right_to_work_or_study: 'yes', right_to_work_or_study_details: 'I have Settled status')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status)).to eq('I have Settled status')
    end

    it 'returns correct message if the candidates answered they do not yet have the right to work/study in the UK' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'Canadian',
                                                                                         right_to_work_or_study: 'no')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status)).to eq('Candidate needs to apply for permission to work and study in the UK')
    end

    it 'returns correct message if the candidates answered they do not know if they have the right to work/study in the UK' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'Canadian',
                                                                                         right_to_work_or_study: 'decide_later')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :candidate, :uk_residency_status)).to eq('Candidate does not know')
    end
  end

  describe 'attributes.contact_details' do
    it 'returns contact details in correct format for UK addresses' do
      application_form_attributes = {
        phone_number: '07700 900 982',
        address_line1: '42',
        address_line2: 'Much Wow Street',
        address_line3: 'London',
        address_line4: 'England',
        country: 'GB',
        postcode: 'SW1P 3BT',
      }
      application_form = create(
        :completed_application_form,
        :with_completed_references,
        application_form_attributes,
      )
      application_choice = create(
        :application_choice,
        status: 'awaiting_provider_decision',
        application_form: application_form,
      )

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expected_contact_details = application_form_attributes.merge(email: application_form.candidate.email_address)
      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response.dig(:attributes, :contact_details)).to eq expected_contact_details
    end

    it 'returns contact details in correct format for international addresses' do
      application_form_attributes = {
        phone_number: '07700 900 982',
        address_type: 'international',
        international_address: '456 Marine Drive, Mumbai',
        country: 'IN',
      }
      application_form = create(
        :completed_application_form,
        :with_completed_references,
        application_form_attributes,
      )
      application_choice = create(
        :application_choice,
        status: 'awaiting_provider_decision',
        application_form: application_form,
      )

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response.dig(:attributes, :contact_details)).to eq({
        phone_number: '07700 900 982',
        address_line1: '456 Marine Drive, Mumbai',
        country: 'IN',
        email: application_form.candidate.email_address,
      })
    end
  end

  describe 'attributes.safeguarding_issues_status' do
    it 'returns the safeguarding issues status' do
      application_form = create(:completed_application_form, :with_safeguarding_issues_disclosed)
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :safeguarding_issues_status)).to eq('has_safeguarding_issues_to_declare')
    end
  end

  describe 'attributes.safeguarding_issues_details_url' do
    it 'returns the url if the status is has_safeguarding_issues_to_declare' do
      application_form = create(:completed_application_form, :with_safeguarding_issues_disclosed)
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :safeguarding_issues_details_url)).to include("/provider/applications/#{application_choice.id}#criminal-convictions-and-professional-misconduct")
    end

    it 'returns nil if the status is no_safeguarding_issues_to_declare' do
      application_form = create(:completed_application_form, :with_no_safeguarding_issues_to_declare)
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :safeguarding_issues_details_url)).to eq(nil)
    end

    it 'returns nil if the status is never_asked' do
      application_form = create(:completed_application_form, :with_safeguarding_issues_never_asked)
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorAPI::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.dig(:attributes, :safeguarding_issues_details_url)).to eq(nil)
    end
  end

  describe 'attributes.references' do
    let(:application_choice) { create(:application_choice, :with_offer) }

    it 'returns only references with feedback' do
      with_feedback = create(
        :reference,
        :feedback_provided,
        application_form: application_choice.application_form,
      )

      refused = create(
        :reference,
        :feedback_refused,
        application_form: application_choice.application_form,
      )

      presenter = VendorAPI::SingleApplicationPresenter.new(application_choice)
      expect(presenter.as_json[:attributes][:references].map { |r| r[:id] }).to include(with_feedback.id)
      expect(presenter.as_json[:attributes][:references].map { |r| r[:id] }).not_to include(refused.id)
    end

    it 'returns application references with their respective ids' do
      reference = create(
        :reference,
        :feedback_provided,
        application_form: application_choice.application_form,
      )
      presenter = VendorAPI::SingleApplicationPresenter.new(application_choice)
      expect(presenter.as_json[:attributes][:references].first[:id]).to eq(reference.id)
    end

    it 'includes safeguarding concerns' do
      create(
        :reference,
        :feedback_provided,
        safeguarding_concerns_status: 'has_safeguarding_concerns_to_declare',
        application_form: application_choice.application_form,
      )

      create(
        :reference,
        :feedback_provided,
        safeguarding_concerns_status: 'no_safeguarding_concerns_to_declare',
        application_form: application_choice.application_form,
      )

      presenter = VendorAPI::SingleApplicationPresenter.new(application_choice)
      expect(presenter.as_json[:attributes][:references].map { |r| r[:safeguarding_concerns] })
        .to match_array [true, false]
    end
  end

  describe 'attributes.qualifications' do
    let(:application_choice) { create(:application_choice, :with_offer) }
    let(:presenter) { VendorAPI::SingleApplicationPresenter.new(application_choice) }

    it 'contains HESA qualification fields' do
      create(
        :other_qualification,
        :non_uk,
        application_form: application_choice.application_form,
      )

      qualification_hash = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :other_qualifications,
      ).first

      expect(qualification_hash).to have_key(:hesa_degstdt)
    end

    it 'contains equivalency_details' do
      qualification = create(
        :other_qualification,
        :non_uk,
        application_form: application_choice.application_form,
      )

      equivalency_details = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :other_qualifications,
      ).first[:equivalency_details]

      expect(equivalency_details).to eq(qualification.equivalency_details)
    end

    it 'adds NARIC information, if present, to equivalency_details' do
      qualification = create(
        :gcse_qualification,
        :non_uk,
        application_form: application_choice.application_form,
      )

      equivalency_details = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :gcses,
      ).first[:equivalency_details]

      composite_equivalency_details = [
        "Naric: #{qualification.naric_reference}",
        qualification.comparable_uk_qualification,
        qualification.equivalency_details,
      ].join(' - ')

      expect(equivalency_details).to eq(composite_equivalency_details)
    end

    it 'includes a non_uk_qualification_type for non-UK qualifications' do
      create(
        :gcse_qualification,
        :non_uk,
        non_uk_qualification_type: 'High School Diploma',
        application_form: application_choice.application_form,
      )

      qualification = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :gcses,
      ).find { |q| q[:non_uk_qualification_type] == 'High School Diploma' }

      expect(qualification[:non_uk_qualification_type]).to eq 'High School Diploma'
    end

    it 'adds GCSE science triple award information' do
      science_triple_awards = {
        biology: 'A',
        chemistry: 'B',
        physics: 'C',
      }

      create(
        :gcse_qualification,
        grade: nil,
        subject: 'science triple award',
        structured_grades: science_triple_awards,
        application_form: application_choice.application_form,
      )

      qualification = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :gcses,
      ).find { |q| q[:subject] == 'science triple award' }

      expect(qualification[:grade]).to eq 'ABC'
    end

    it 'parses English GCSE structured grades' do
      create(
        :gcse_qualification,
        subject: 'english',
        grade: nil,
        structured_grades: '{"english_language":"E","english_literature":"E","Cockney Rhyming Slang":"A*"}',
        award_year: 2006,
        predicted_grade: false,
        application_form: application_choice.application_form,
      )

      english_language = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :gcses,
      ).find { |q| q[:subject] == 'English language' }

      expect(english_language[:grade]).to eq 'E'

      english_literature = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :gcses,
      ).find { |q| q[:subject] == 'English literature' }

      expect(english_literature[:grade]).to eq 'E'

      rhyming_slang = presenter.as_json.dig(
        :attributes,
        :qualifications,
        :gcses,
      ).find { |q| q[:subject] == 'Cockney rhyming slang' }

      expect(rhyming_slang[:grade]).to eq 'A*'
    end
  end

  describe 'attributes.offer' do
    it 'includes an offer_made_at date for offers' do
      choice = create(:application_choice, :with_offer)

      presenter = VendorAPI::SingleApplicationPresenter.new(choice)
      expect(presenter.as_json[:attributes][:offer][:offer_made_at]).to be_present
    end

    it 'includes an accepted_at date for accepted offers' do
      choice = create(:application_choice, :with_accepted_offer)

      presenter = VendorAPI::SingleApplicationPresenter.new(choice)
      expect(presenter.as_json[:attributes][:offer][:offer_accepted_at]).to be_present
    end

    it 'includes a declined_at date for declined offers' do
      choice = create(:application_choice, :with_declined_offer)

      presenter = VendorAPI::SingleApplicationPresenter.new(choice)
      expect(presenter.as_json[:attributes][:offer][:offer_declined_at]).to be_present
    end
  end

  describe 'attributes.recruited_at' do
    it 'includes the date the candidate was recruited' do
      choice = create(:application_choice, :with_recruited)

      presenter = VendorAPI::SingleApplicationPresenter.new(choice)
      expect(presenter.as_json[:attributes][:recruited_at]).to be_present
    end
  end
end
