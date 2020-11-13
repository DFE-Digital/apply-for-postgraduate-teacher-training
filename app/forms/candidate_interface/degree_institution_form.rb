module CandidateInterface
  class DegreeInstitutionForm
    include ActiveModel::Model

    attr_accessor :degree, :institution_name, :institution_country

    delegate :international?, to: :degree, allow_nil: true

    validates :institution_name, presence: true
    validates :institution_name, length: { maximum: 255 }
    validates :institution_country, presence: true, if: -> { international? }
    validates :institution_country, length: { maximum: 255 }

    def save
      return false unless valid?

      degree.update!(
        institution_name: institution_name,
        institution_country: institution_country,
        institution_hesa_code: hesa_code,
      )
    end

    def assign_form_values
      self.institution_name = degree.institution_name
      self.institution_country = degree.institution_country
      self
    end

  private

    def hesa_code
      Hesa::Institution.find_by_name(institution_name)&.hesa_code
    end
  end
end
