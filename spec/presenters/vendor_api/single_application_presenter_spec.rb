require 'rails_helper'

RSpec.describe VendorApi::SingleApplicationPresenter do
  subject(:presenter) { described_class.new(application_choice) }

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  describe '#as_json' do
    def json
      @json ||= presenter.as_json.deep_symbolize_keys
    end

    def application_choice
      @application_choice ||= create(:application_choice)
    end

    def expected_attributes
      {
        id: application_choice.id.to_s,
        type: 'application',
        attributes: {
          personal_statement: application_choice.personal_statement,
          hesa_itt_data: {
            disability: '',
            ethnicity: '',
            sex: '',
          },
          offer: nil,
          contact_details: {
            phone_number: application_choice.application_form.phone_number,
            address_line1: application_choice.application_form.address_line1,
            address_line2: application_choice.application_form.address_line2,
            address_line3: application_choice.application_form.address_line3,
            address_line4: application_choice.application_form.address_line4,
            postcode: application_choice.application_form.postcode,
            country: 'UK',
            email: application_choice.application_form.candidate.email_address,
          },
          course: {
            start_date: application_choice.course.start_date,
            provider_ucas_code: application_choice.provider.code,
            site_ucas_code: application_choice.course_option.site.code,
            course_ucas_code: application_choice.course.code,
          },
          candidate: {
            first_name: application_choice.application_form.first_name,
            last_name: application_choice.application_form.last_name,
            date_of_birth: application_choice.application_form.date_of_birth,
            nationality: nationalities(application_choice.application_form),
            uk_residency_status: application_choice.application_form.uk_residency_status,
            english_main_language: application_choice.application_form.english_main_language,
            english_language_qualifications: application_choice.application_form.english_language_details,
            other_languages: application_choice.application_form.other_language_details,
            disability_disclosure: application_choice.application_form.disability_disclosure,
          },
          qualifications: {
            gcses: [
              {
                qualification_type: 'GCSE',
                subject: 'Maths',
                grade: 'A',
                award_year: '2001',
                equivalency_details: nil,
                institution_details: nil,
              },
              {
                qualification_type: 'GCSE',
                subject: 'English',
                grade: 'A',
                award_year: '2001',
                equivalency_details: nil,
                institution_details: nil,
              },
            ],
            degrees: [
              {
                qualification_type: 'BA',
                subject: 'Geography',
                grade: '2.1',
                award_year: '2007',
                equivalency_details: nil,
                institution_details: 'Imperial College London',
              },
            ],
            other_qualifications: [
              {
                qualification_type: 'A Level',
                subject: 'Chemistry',
                grade: 'B',
                award_year: '2004',
                equivalency_details: nil,
                institution_details: 'Harris Westminster Sixth Form',
              },
            ],
          },
          references: [
            {
              name: 'John Smith',
              email: 'johnsmith@example.com',
              phone_number: '07999 111111',
              relationship: 'BA Geography course director at Imperial College. I tutored the candidate for one academic year.',
              confirms_safe_to_work_with_children: true,
              reference: <<~HEREDOC,
                Fantastic personality. Great with people. Strong communicator .  Excellent character. Passionate about teaching . Great potential.  A charismatic talented able young person who is far better than her official degree result. An exceptional person.

                Passion for their subject	7 / 10
                Knowledge about their subject	10 / 10
                General academic performance	9 / 10
                Ability to meet deadlines and organise their time	7 / 10
                Ability to think critically	10 / 10
                Ability to work collaboratively	Don’t know
                Mental and emotional resilience	8 / 10
                Literacy	9 / 10
                Numeracy	7 / 10
              HEREDOC
            },
            {
              name: 'Jane Brown',
              email: 'janebrown@example.com',
              phone_number: '07111 999999',
              relationship: 'Headmistress at Harris Westminster Sixth Form',
              confirms_safe_to_work_with_children: true,
              reference: <<~HEREDOC,
                An ideal teacher. Brisk and lively communicator. Intelligent and self-aware. Good with children. Led education outreach workshops.

                Passion for their subject	7 / 10
                Knowledge about their subject	10 / 10
                General academic performance	9 / 10
                Ability to meet deadlines and organise their time	7 / 10
                Ability to think critically	10 / 10
                Ability to work collaboratively	Don’t know
                Mental and emotional resilience	8 / 10
                Literacy	9 / 10
                Numeracy	7 / 10
              HEREDOC
            },
          ],
          rejection: nil,
          status: application_choice.status,
          submitted_at: application_choice.application_form.submitted_at,
          updated_at: application_choice.updated_at,
          withdrawal: nil,
          further_information: application_choice.application_form.further_information,
          work_experience: {
            jobs: [
              {
                start_date: application_choice.application_form.application_work_experiences.first.start_date.to_date,
                end_date: application_choice.application_form.application_work_experiences.first.end_date&.to_date,
                role: application_choice.application_form.application_work_experiences.first.role,
                organisation_name: application_choice.application_form.application_work_experiences.first.organisation,
                working_with_children: application_choice.application_form.application_work_experiences.first.working_with_children,
                commitment: application_choice.application_form.application_work_experiences.first.commitment,
                description: application_choice.application_form.application_work_experiences.first.details,
              },
            ],
            volunteering: [
              {
                start_date: application_choice.application_form.application_volunteering_experiences.first.start_date.to_date,
                end_date: application_choice.application_form.application_volunteering_experiences.first.end_date&.to_date,
                role: application_choice.application_form.application_volunteering_experiences.first.role,
                organisation_name: application_choice.application_form.application_volunteering_experiences.first.organisation,
                working_with_children: application_choice.application_form.application_volunteering_experiences.first.working_with_children,
                commitment: application_choice.application_form.application_volunteering_experiences.first.commitment,
                description: application_choice.application_form.application_volunteering_experiences.first.details,
              },
            ],
          },
        },
      }
    end

    it 'returns correct application attributes' do
      expect(json).to eq expected_attributes
    end

    def nationalities(application_form)
      [
        application_form.first_nationality,
        application_form.second_nationality,
      ].map { |n|
        NATIONALITIES.to_h.invert[n]
      }.compact
    end
  end
end
