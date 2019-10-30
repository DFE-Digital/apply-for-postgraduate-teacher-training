module CandidateInterface
  class DegreesForm
    include ActiveModel::Model

    attr_accessor :qualification_type, :subject, :institution_name, :grade,
                  :other_grade, :predicted_grade, :award_year

    validates :qualification_type, :subject, :institution_name, :grade, presence: true
    validates :other_grade, presence: true, if: :other_grade?
    validates :predicted_grade, presence: true, if: :predicted_grade?
    validates :award_year, presence: true

    validates :qualification_type, :subject, :institution_name, length: { maximum: 255 }
    validates :other_grade, :predicted_grade, length: { maximum: 255 }

    validate :award_year_is_date, if: :award_year

    def save_base(application_form)
      return false unless valid?

      application_form.application_qualifications.create!(
        level: ApplicationQualification.levels['degree'],
        qualification_type: qualification_type,
        subject: subject,
        institution_name: institution_name,
        grade: grade,
        award_year: award_year,
      )

      true
    end

  private

    def other_grade?
      grade == 'other'
    end

    def predicted_grade?
      grade == 'predicted'
    end

    def award_year_is_date
      valid_award_year = award_year.match(/^[1-9]\d{3}$/)
      errors.add(:award_year, :invalid) unless valid_award_year
    end
  end
end
