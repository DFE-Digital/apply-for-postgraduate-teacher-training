module CandidateInterface
  class DegreeYearForm
    include ActiveModel::Model

    attr_accessor :start_year, :award_year, :degree

    validates :start_year, year: true, presence: true
    validates :award_year, year: true, presence: true
    validate :start_year_is_before_the_award_year, unless: ->(c) { c.errors.attribute_names.include?(:start_year) }
    validate :award_year_is_before_the_end_of_next_year, unless: ->(c) { c.errors.attribute_names.include?(:award_year) }
    validate :award_year_is_in_the_future_for_incomplete_degree, unless: ->(c) { c.errors.attribute_names.include?(:award_year) }

    def save
      return false unless valid?

      degree.update!(start_year: start_year, award_year: award_year)
    end

    def assign_form_values
      self.start_year = degree.start_year
      self.award_year = degree.award_year
      self
    end

  private

    def start_year_is_before_the_award_year
      errors.add(:start_year, :greater_than_award_year, date: award_year) if award_year.present? && award_year.to_i < start_year.to_i
    end

    def award_year_is_in_the_future_for_incomplete_degree
      errors.add(:award_year, :in_the_future) if award_year.present? && award_year.to_i < Time.zone.now.year.to_i
    end

    def award_year_is_before_the_end_of_next_year
      upper_year_limit = Time.zone.now.year.to_i + 2

      errors.add(:award_year, :greater_than_limit, date: upper_year_limit) if award_year.to_i >= upper_year_limit
    end
  end
end
