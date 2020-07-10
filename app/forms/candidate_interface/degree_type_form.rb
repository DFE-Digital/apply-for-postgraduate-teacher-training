module CandidateInterface
  class DegreeTypeForm
    include ActiveModel::Model

    attr_accessor :type_description
    attr_accessor :uk_degree
    attr_accessor :application_form, :degree

    validates :uk_degree, presence: true, if: -> { FeatureFlag.active?(:international_degrees) }
    validates :type_description, presence: true
    validates :type_description, length: { maximum: 255 }

    def save
      return false unless valid?
      return false unless application_form_present?

      self.degree = application_form.application_qualifications.degree.create!(
        international: international?,
        qualification_type: type_description,
        qualification_type_hesa_code: hesa_code,
      )
    end

    def update
      return false unless valid?
      return false unless degree_present?

      degree.update!(
        international: international?,
        qualification_type: type_description,
        qualification_type_hesa_code: hesa_code,
      )
    end

    def fill_form_values
      self.uk_degree = !degree.international?
      self.type_description = degree.qualification_type
      self
    end

  private

    def hesa_code
      Hesa::DegreeType.find_by_name(type_description)&.hesa_code
    end

    def application_form_present?
      if application_form.present?
        true
      else
        errors.add(:application_form, 'is missing')
        false
      end
    end

    def degree_present?
      if degree.present?
        true
      else
        errors.add(:degree, 'is missing')
        false
      end
    end

    def international?
      FeatureFlag.active?(:international_degrees) && uk_degree == 'no'
    end
  end
end
