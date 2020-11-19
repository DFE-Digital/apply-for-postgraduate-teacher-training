module CandidateInterface
  class EnglishGcseGradeForm
    include ActiveModel::Model
    include ValidationUtils

    attr_accessor :grade,
                  :qualification,
                  :other_grade,
                  :structured_grades,
                  :english_gcses,
                  :english_single_award,
                  :grade_english_single,
                  :english_double_award,
                  :grade_english_double,
                  :english_language,
                  :grade_english_language,
                  :english_literature,
                  :grade_english_literature,
                  :english_studies_single_award,
                  :grade_english_studies_single,
                  :english_studies_double_award,
                  :grade_english_studies_double,
                  :other_english_gcse,
                  :other_english_gcse_name,
                  :grade_other_english_gcse,
                  :award_year

    validates :grade, presence: true, on: :grade
    validates :other_grade, presence: true, if: :grade_is_other?
    validate :validate_grade_format, on: :grade, unless: :is_multiple_gcse? || :new_record?
    validate :validate_grades, unless: :new_record?, on: :structured_grades, if: :is_multiple_gcse?
    validate :gcse_selected, on: :structured_grades, if: :is_multiple_gcse?

    class << self
      def build_from_qualification(qualification)
        if qualification.qualification_type == 'non_uk'
          new(grade: qualification.set_grade,
              other_grade: qualification.set_other_grade,
              qualification: qualification)
        else
          new(build_params_from(qualification))
        end
      end

    private

      def build_params_from(qualification)
        params = {
          grade: qualification.grade,
          qualification: qualification,
        }

        if qualification.structured_grades
          grades = JSON.parse(qualification.structured_grades)
          english_gcses = []

          if grades.keys.include? 'english_single_award'
            english_gcses << 'english_single_award'
            params[:grade_english_single] = grades['english_single_award']
            params[:english_single_award] = true
          end

          if grades.keys.include? 'english_double_award'
            english_gcses << 'english_double_award'
            params[:grade_english_double] = grades['english_double_award']
            params[:english_double_award] = true
          end

          if grades.keys.include? 'english_language'
            english_gcses << 'english_language'
            params[:grade_english_language] = grades['english_language']
            params[:english_language] = true
          end

          if grades.keys.include? 'english_literature'
            english_gcses << 'english_literature'
            params[:grade_english_literature] = grades['english_literature']
            params[:english_literature] = true
          end

          if grades.keys.include? 'english_studies_single_award'
            english_gcses << 'english_studies_single_award'
            params[:grade_english_studies_single] = grades['english_studies_single_award']
            params[:english_studies_single_award] = true
          end

          if grades.keys.include? 'english_studies_double_award'
            english_gcses << 'english_studies_double_award'
            params[:grade_english_studies_double] = grades['english_studies_double_award']
            params[:english_studies_double_award] = true
          end

          other_english_gcse_name = grades.keys.select { |k|
            %w[
              english_single_award english_double_award
              english_language
              english_literature
              english_studies_single_award english_studies_double_award
            ].exclude? k
          } .first

          english_gcses << 'other_english_gcse' if other_english_gcse_name
          params[:english_gcses] = english_gcses

          params[:other_english_gcse] = other_english_gcse_name
          params[:other_english_gcse_name] = other_english_gcse_name if other_english_gcse_name
          params[:grade_other_english_gcse] = grades[other_english_gcse_name] if other_english_gcse_name
        end

        params
      end
    end

    def assign_values(params)
      if is_multiple_gcse?
        english_gcses = params[:english_gcses]
        self.english_gcses = english_gcses

        self.english_single_award = english_gcses.include? 'english_single_award'
        self.grade_english_single = params[:grade_english_single]

        self.english_double_award = english_gcses.include? 'english_double_award'
        self.grade_english_double = params[:grade_english_double]

        self.english_language = english_gcses.include? 'english_language'
        self.grade_english_language = params[:grade_english_language]

        self.english_literature = english_gcses.include? 'english_literature'
        self.grade_english_literature = params[:grade_english_literature]

        self.english_studies_single_award = english_gcses.include? 'english_studies_single_award'
        self.grade_english_studies_single = params[:grade_english_studies_single]

        self.english_studies_double_award = english_gcses.include? 'english_studies_double_award'
        self.grade_english_studies_double = params[:grade_english_studies_double]

        self.other_english_gcse = english_gcses.include? 'other_english_gcse'
        self.other_english_gcse_name = params[:other_english_gcse_name]
        self.grade_other_english_gcse = params[:grade_other_english_gcse]
      else
        self.grade = params[:grade]
        self.other_grade = params [:other_grade]
      end
      self
    end

    def save_grades
      if !valid?(:structured_grades)
        log_validation_errors(:structured_grades)
        return false
      end
      qualification.update(structured_grades: build_grades_json, grade: nil)
    end

    def save_grade
      if !valid?(:grade)
        log_validation_errors(:grade)
        return false
      end
      qualification.update(grade: set_grade, structured_grades: nil)
    end

  private

    def build_grades_json
      grades = {}.tap do |model|
        model[:english_single_award] = grade_english_single if english_single_award
        model[:english_double_award] = grade_english_double if english_double_award
        model[:english_language] = grade_english_language if english_language
        model[:english_literature] = grade_english_literature if english_literature
        model[:english_studies_single_award] = grade_english_studies_single if english_studies_single_award
        model[:english_studies_double_award] = grade_english_studies_double if english_studies_double_award
        model[other_english_gcse_name] = grade_other_english_gcse if other_english_gcse
      end
      grades.to_json if grades.any?
    end

    def gcse_selected
      if english_gcses.nil? || english_gcses.reject(&:empty?).empty?
        errors.add(:english_gcses, :blank)
      end
    end

    def validate_grades
      if english_single_award
        errors.add(:grade_english_single, :blank) if grade_english_single.blank?
        errors.add(:grade_english_single, :invalid) unless SINGLE_GCSE_GRADES.include?(grade_english_single.strip.upcase)
      end

      if english_double_award
        errors.add(:grade_english_double, :blank) if grade_english_double.blank?
        errors.add(:grade_english_double, :invalid) unless DOUBLE_GCSE_GRADES.include?(grade_english_double.delete(' ').upcase)
      end

      if english_language
        errors.add(:grade_english_language, :blank) if grade_english_language.blank?
        errors.add(:grade_english_language, :invalid) unless SINGLE_GCSE_GRADES.include?(grade_english_language.strip.upcase)
      end

      if english_literature
        errors.add(:grade_english_literature, :blank) if grade_english_literature.blank?
        errors.add(:grade_english_literature, :invalid) unless SINGLE_GCSE_GRADES.include?(grade_english_literature.strip.upcase)
      end

      if english_studies_single_award
        errors.add(:grade_english_studies_single, :blank) if grade_english_studies_single.blank?
        errors.add(:grade_english_studies_single, :invalid) unless SINGLE_GCSE_GRADES.include?(grade_english_studies_single.strip.upcase)
      end

      if english_studies_double_award
        errors.add(:grade_english_studies_double, :blank) if grade_english_studies_double.blank?
        errors.add(:grade_english_studies_double, :invalid) unless DOUBLE_GCSE_GRADES.include?(grade_english_studies_double.delete(' ').upcase)
      end

      if other_english_gcse
        errors.add(:other_english_gcse_name, :blank) if other_english_gcse_name.blank?
        errors.add(:grade_other_english_gcse, :blank) if grade_other_english_gcse.blank?
        errors.add(:grade_other_english_gcse, :invalid) unless SINGLE_GCSE_GRADES.include?(grade_other_english_gcse.strip.upcase)
      end
    end

    def validate_grade_format
      return if qualification.qualification_type.nil? || qualification.qualification_type == 'other_uk' || qualification.qualification_type == 'non_uk'

      qualification_rexp = invalid_grades[qualification.qualification_type.to_sym]

      if qualification_rexp && grade.match(qualification_rexp)
        errors.add(:grade, :invalid)
      end
    end

    def invalid_grades
      {
        gcse: /[^1-9A-GU\*\s\-]/i,
        gce_o_level: /[^A-EU\s\-]/i,
        scottish_national_5: /[^A-D1-7\s\-]/i,
      }
    end

    def new_record?
      qualification.nil?
    end

    def log_validation_errors(field)
      return unless errors.key?(field)

      error_message = {
        field: field.to_s,
        error_messages: errors[field].join(' - '),
        value: instance_values[field.to_s],
      }

      Rails.logger.info("Validation error: #{error_message.inspect}")
    end

    def grade_is_other?
      grade == 'other'
    end

    def set_grade
      case grade
      when 'other'
        other_grade
      when 'not_applicable'
        'N/A'
      when 'unknown'
        'Unknown'
      else
        grade
      end
    end

    def multiple_gsces_are_active?
      FeatureFlag.active?('multiple_english_gcses')
    end

    def is_multiple_gcse?
      qualification.qualification_type == 'gcse' && multiple_gsces_are_active?
    end
  end
end
