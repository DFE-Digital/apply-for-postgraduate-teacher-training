module CandidateInterface
  class PersonalDetailsForm
    include ActiveModel::Model

    attr_accessor :first_name, :last_name,
                  :day, :month, :year,
                  :first_nationality, :second_nationality,
                  :english_main_language,
                  :english_language_details, :other_language_details

    validates :first_name, :last_name, :english_main_language,
              :first_nationality,
              presence: true

    validates :first_name, :last_name,
              length: { maximum: 100 }

    validate :date_of_birth_cannot_be_in_the_future

    validates :first_nationality, :second_nationality,
              inclusion: { in: NATIONALITIES, allow_blank: true }

    validates :english_language_details, :other_language_details,
              word_count: { maximum: 200 }

    def name
      "#{first_name} #{last_name}"
    end

    def date_of_birth
      date_args = [year, month, day].map(&:to_i)
      if Date.valid_date?(*date_args)
        Date.new(*date_args)
      else
        nil
      end
    end

    def date_of_birth_cannot_be_in_the_future
      raise 'Invalid date' if [year, month, day].any?(&:blank?)

      errors.add(:date_of_birth, :future) if date_of_birth > Date.today
    rescue RuntimeError, NoMethodError
      errors.add(:date_of_birth, :invalid)
    end
  end
end
