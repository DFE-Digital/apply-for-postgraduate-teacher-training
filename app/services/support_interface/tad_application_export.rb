module SupportInterface
  class TADApplicationExport
    attr_reader :application_choice

    delegate :course_option, :course, :application_form, to: :application_choice
    delegate :candidate, to: :application_form

    def initialize(application_choice)
      @application_choice = application_choice
    end

    def as_json
      accrediting_provider = course.accredited_provider || application_choice.provider
      degree = application_form.application_qualifications.find { |q| q.level == 'degree' }
      equality_and_diversity = application_form.equality_and_diversity.to_h

      # https://docs.google.com/spreadsheets/d/1TBQiWpx7Nks4lD2JyXCYp6M69VIGpf-Oi0s_nGK8arA
      {
        # Internal identifiers
        candidate_id: application_form.candidate.id,
        application_choice_id: application_choice.id,
        application_form_id: application_form.id,

        # State
        status: application_choice.status,
        phase: application_form.phase,

        # Personal information
        first_name: application_form.first_name,
        last_name: application_form.last_name,
        date_of_birth: application_form.date_of_birth,
        email: candidate.email_address,
        postcode: application_form.postcode,
        country: application_form.country,
        nationality: concatenate(nationalities),

        # HESA data
        sex: equality_and_diversity['hesa_sex'],
        disability: equality_and_diversity['hesa_disabilities'],
        ethnicity: equality_and_diversity['hesa_ethnicity'],

        # The candidate's degree
        degree_classification: degree&.grade,
        degree_classification_hesa_code: degree&.grade_hesa_code,

        # Provider
        provider_code: application_choice.provider.code,
        provider_id: application_choice.provider.id,
        provider_name: application_choice.provider.name,
        accrediting_provider_code: accrediting_provider.code,
        accrediting_provider_id: accrediting_provider.id,
        accrediting_provider_name: accrediting_provider.name,

        course_level: course.level,
        program_type: application_choice.course.program_type,
        programme_outcome: application_choice.course.description,
        course_name: application_choice.course.name,
        course_code: application_choice.course.code,
        nctl_subject: concatenate(application_choice.course.subject_codes),
      }
    end

  private

    def nationalities
      [
        application_form.first_nationality,
        application_form.second_nationality,
        application_form.third_nationality,
        application_form.fourth_nationality,
        application_form.fifth_nationality,
      ].map { |n| NATIONALITIES_BY_NAME[n] }.compact.uniq
        .sort.partition { |e| %w[GB IE].include? e }.flatten
    end

    def concatenate(array)
      array.to_a.join('|')
    end
  end
end
