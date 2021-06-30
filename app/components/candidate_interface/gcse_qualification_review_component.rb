module CandidateInterface
  class GcseQualificationReviewComponent < ViewComponent::Base
    def initialize(application_form:, application_qualification:, subject:, editable: true, heading_level: 2, missing_error: false, submitting_application: false)
      @application_form = application_form
      @application_qualification = application_qualification
      @subject = subject
      @editable = editable
      @heading_level = heading_level
      @missing_error = missing_error
      @submitting_application = submitting_application
    end

    def gcse_qualification_rows
      if application_qualification.missing_qualification?
        [missing_qualification_row]
      else
        [
          qualification_row,
          country_row,
          enic_statement_row,
          enic_reference_row,
          comparable_uk_qualification_row,
          grade_row,
          failing_grade_explanation_row,
          award_year_row,
        ].compact
      end
    end

    def show_missing_banner?
      if @submitting_application
        gcse_completed = "#{@subject}_gcse_completed"
        !@application_form.send(gcse_completed) && @editable
      end
    end

    def show_values_missing_banner?
      if @submitting_application
        section_or_gcse_incomplete? && @editable
      end
    end

  private

    attr_reader :application_qualification, :subject

    def section_or_gcse_incomplete?
      gcse_completed = "#{@subject}_gcse_completed"
      (!@application_form.send(gcse_completed) || @application_form.send("#{@subject}_gcse").incomplete_gcse_information?) && !@application_qualification.missing_qualification?
    end

    def qualification_row
      {
        key: t('application_form.gcse.qualification.label'),
        value: gcse_qualification_types[application_qualification.qualification_type.to_sym.downcase],
        action: {
          href: candidate_interface_gcse_details_edit_type_path(subject: subject),
          visually_hidden_text: "qualification for #{gcse_qualification_types[application_qualification.qualification_type.to_sym]}, #{subject}",
        },
      }
    end

    def award_year_row
      {
        key: 'Year awarded',
        value: application_qualification.award_year || t('gcse_summary.not_specified'),
        action: {
          href: candidate_interface_gcse_details_edit_year_path(subject: subject),
          visually_hidden_text: "year awarded for #{gcse_qualification_types[application_qualification.qualification_type.to_sym]}, #{subject}",
        },
      }
    end

    def grade_row
      {
        key: 'Grade',
        value: present_grades || t('gcse_summary.not_specified'),
        action: {
          href: grade_edit_path,
          visually_hidden_text: "grade for #{gcse_qualification_types[application_qualification.qualification_type.to_sym]}, #{subject}",
        },
      }
    end

    def failing_grade_explanation_row
      return nil unless application_qualification.failed_required_gcse? && application_qualification.missing_explanation.present?

      {
        key: 'How I expect to gain this qualification',
        value: application_qualification.missing_explanation,
        action: {
          href: candidate_interface_gcse_details_edit_grade_explanation_path(subject: subject),
          visually_hidden_text: 'if you are working towards this qualification at grade 4 (C) or above, give us details',
        },
      }
    end

    def present_grades
      case application_qualification.subject
      when ApplicationQualification::SCIENCE_TRIPLE_AWARD
        grades = application_qualification.constituent_grades
        [
          "#{grades['biology']['grade']} (Biology)",
          "#{grades['chemistry']['grade']} (Chemistry)",
          "#{grades['physics']['grade']} (Physics)",
        ]
      when ApplicationQualification::SCIENCE_DOUBLE_AWARD
        "#{application_qualification.grade} (Double award)"
      when ApplicationQualification::SCIENCE_SINGLE_AWARD
        "#{application_qualification.grade} (Single award)"
      when ->(_n) { application_qualification.constituent_grades }
        present_constituent_grades
      else
        application_qualification.grade
      end
    end

    def present_constituent_grades
      grades = application_qualification.constituent_grades
      grades.map do |k, v,|
        grade = v['grade']
        case k
        when 'english_single_award'
          "#{grade} (English Single award)"
        when 'english_double_award'
          "#{grade} (English Double award)"
        when 'english_studies_single_award'
          "#{grade} (English Studies Single award)"
        when 'english_studies_double_award'
          "#{grade} (English Studies Double award)"
        else
          "#{grade} (#{k.humanize.titleize})"
        end
      end
    end

    def missing_qualification_row
      {
        key: 'How I expect to gain this qualification',
        value: application_qualification.missing_explanation.presence || t('gcse_summary.not_specified'),
        action: {
          href: candidate_interface_gcse_details_edit_type_path(subject: subject),
          visually_hidden_text: 'how you expect to gain this qualification',
        },
      }
    end

    def gcse_qualification_types
      t('application_form.gcse.qualification_types').merge(
        other_uk: application_qualification.other_uk_qualification_type,
        non_uk: application_qualification.non_uk_qualification_type,
      )
    end

    def country_row
      return nil unless application_qualification.qualification_type == 'non_uk'

      {
        key: 'Country',
        value: COUNTRIES[application_qualification.institution_country],
        action: {
          href: candidate_interface_gcse_details_edit_institution_country_path(subject: subject),
          visually_hidden_text: 'the country that you studied in',
        },
      }
    end

    def enic_statement_row
      return nil unless application_qualification.qualification_type == 'non_uk'

      {
        key: t('application_form.gcse.enic_statement.review_label'),
        value: application_qualification.enic_reference ? 'Yes' : 'No',
        action: {
          href: candidate_interface_gcse_details_edit_enic_path(subject: subject),
          visually_hidden_text: t('application_form.gcse.enic_statement.change_action'),
        },
      }
    end

    def enic_reference_row
      return nil unless application_qualification.qualification_type == 'non_uk' &&
        application_qualification.enic_reference

      {
        key: t('application_form.gcse.enic_reference.review_label'),
        value: application_qualification.enic_reference,
        action: {
          href: candidate_interface_gcse_details_edit_enic_path(subject: subject),
          visually_hidden_text: t('application_form.gcse.enic_reference.change_action'),
        },
      }
    end

    def comparable_uk_qualification_row
      return nil unless application_qualification.qualification_type == 'non_uk' &&
        application_qualification.enic_reference

      {
        key: t('application_form.gcse.comparable_uk_qualification.review_label'),
        value: application_qualification.comparable_uk_qualification,
        action: {
          href: candidate_interface_gcse_details_edit_enic_path(subject: subject),
          visually_hidden_text: t('application_form.gcse.comparable_uk_qualification.change_action'),
        },
      }
    end

    def grade_edit_path
      case subject
      when 'maths'
        candidate_interface_edit_gcse_maths_grade_path
      when 'science'
        candidate_interface_edit_gcse_science_grade_path
      when 'english'
        candidate_interface_edit_gcse_english_grade_path
      end
    end
  end
end
