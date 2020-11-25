module CandidateInterface
  class OtherQualificationDetailsForm
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks
    include ActiveModel::Attributes
    include ValidationUtils

    attr_reader :next_step
    attr_accessor :editing, :id, :current_step

    attr_accessor :qualification_type
    attr_accessor :other_uk_qualification_type
    attr_accessor :non_uk_qualification_type
    attr_accessor :subject
    attr_accessor :grade
    attr_accessor :predicted_grade
    attr_accessor :award_year
    attr_accessor :institution_country
    attr_accessor :choice

    before_validation :sanitize_grade_where_required

    validates :qualification_type, presence: true

    validates :award_year, presence: true
    validates :subject, :grade, presence: true, if: -> { qualification_type != OtherQualificationTypeForm::NON_UK_TYPE && qualification_type != OtherQualificationTypeForm::OTHER_TYPE }
    validates :subject, :grade, length: { maximum: 255 }
    validates :institution_country, presence: true, if: -> { qualification_type == OtherQualificationTypeForm::NON_UK_TYPE }
    validates :institution_country, inclusion: { in: COUNTRIES }, if: -> { qualification_type == OtherQualificationTypeForm::NON_UK_TYPE }
    validate :award_year_is_date_and_before_current_year, if: :award_year
    validate :grade_format_is_valid, if: :grade, on: :details

    def self.build_all(application_form)
      application_form.application_qualifications.other.order(:created_at).map do |qualification|
        build_from_qualification(qualification)
      end
    end

    def self.build_from_qualification(qualification)
      form = CandidateInterface::OtherQualificationDetailsForm.new
      form.id = qualification.id
      form.assign_attributes(form.persistent_attributes(qualification))
      form
    end

    def initialize(current_application = nil, intermediate_data_service = nil, options = {})
      @current_application = current_application
      @intermediate_data_service = intermediate_data_service
      options = @intermediate_data_service.read.merge(options) if @intermediate_data_service

      self.id ||= options[:id]
      options = persistent_attributes(current_qualification).merge(options) if current_qualification

      super(options)
    end

    def save_intermediate!
      @intermediate_data_service.write(intermediate_state)
    end

    def save!
      @next_step = :check

      application_qualification = current_qualification ||
        @current_application.application_qualifications.build(
          level: ApplicationQualification.levels[:other],
        )

      application_qualification.assign_attributes(attributes_for_persistence)
      application_qualification.save!
    end

    def initialize_from_last_qualification(qualifications)
      return if qualifications.blank?

      if previous_qualification_is_of_same_type?(qualifications)
        self.institution_country ||= qualifications[-1].institution_country
        self.award_year ||= qualifications[-1].award_year
      end
      if qualification_type == OtherQualificationTypeForm::NON_UK_TYPE
        self.non_uk_qualification_type ||= qualifications[-1].non_uk_qualification_type
      elsif qualification_type == OtherQualificationTypeForm::OTHER_TYPE
        self.other_uk_qualification_type ||= qualifications[-1].other_uk_qualification_type
      end
    end

    def qualification_type_name
      if qualification_type == OtherQualificationTypeForm::NON_UK_TYPE
        non_uk_qualification_type
      elsif qualification_type == OtherQualificationTypeForm::OTHER_TYPE && other_uk_qualification_type.present?
        other_uk_qualification_type
      else
        qualification_type
      end
    end

    def title
      "#{qualification_type_name} #{subject}"
    end

    PERSISTENT_ATTRIBUTES = %w[qualification_type other_uk_qualification_type non_uk_qualification_type subject predicted_grade grade award_year institution_country].freeze
    def persistent_attributes(application_qualification)
      application_qualification.attributes.select { |key, _| PERSISTENT_ATTRIBUTES.include?(key) }
    end

    def missing_type_validation_error?
      valid?
      errors.details[:qualification_type].any? { |e| e[:error] == :blank }
    end

    def grade_hint
      if qualification_type == CandidateInterface::OtherQualificationTypeForm::GCSE_TYPE
        { text: I18n.t('gcse_edit_grade.hint.other.gcse_single_and_double') }
      end
    end

    def current_qualification
      @current_qualification ||= id.present? ? @current_application.application_qualifications.other.find(id) : nil
    end

  private

    def previous_qualification_is_of_same_type?(qualifications)
      last_qualification = qualifications[-1]
      qualification_type == last_qualification.qualification_type
    end

    def attributes_for_persistence
      {
        qualification_type: qualification_type,
        subject: subject,
        institution_country: institution_country,
        predicted_grade: predicted_grade,
        grade: grade,
        other_uk_qualification_type: other_uk_qualification_type,
        non_uk_qualification_type: non_uk_qualification_type,
        award_year: award_year,
      }
    end

    def intermediate_state
      as_json(
        only: %w[id current_step editing qualification_type other_uk_qualification_type non_uk_qualification_type subject institution_country predicted_grade grade award_year],
      )
    end

    def award_year_is_date_and_before_current_year
      if !valid_year?(award_year)
        errors.add(:award_year, :invalid)
      elsif future_year?(award_year)
        errors.add(:award_year, :in_the_future)
      end
    end

    def grade_format_is_valid
      case qualification_type
      when OtherQualificationTypeForm::A_LEVEL_TYPE
        unless grade.in?(A_LEVEL_GRADES)
          errors.add(:grade, :invalid)
        end
      when OtherQualificationTypeForm::AS_LEVEL_TYPE
        unless grade.in?(AS_LEVEL_GRADES)
          errors.add(:grade, :invalid)
        end
      when OtherQualificationTypeForm::GCSE_TYPE
        errors.add(:grade, :invalid) unless grade.in?(ALL_GCSE_GRADES)
      end
    end

    def sanitize_grade_where_required
      if qualification_type.in?([
        OtherQualificationTypeForm::A_LEVEL_TYPE,
        OtherQualificationTypeForm::AS_LEVEL_TYPE,
        OtherQualificationTypeForm::GCSE_TYPE,
      ])
        self.grade = grade.delete(' ').upcase if grade
      end
    end
  end
end
