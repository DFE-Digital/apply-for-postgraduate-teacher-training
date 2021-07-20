class OfferValidations
  include ActiveModel::Model

  MAX_CONDITIONS_COUNT = 20
  # This is required for the API integrations which send conditions together
  MAX_CONDITION_1_LENGTH = 2000
  MAX_CONDITION_LENGTH = 255

  attr_accessor :application_choice, :course_option, :conditions

  validates :course_option, presence: true
  validate :conditions_count, if: :conditions
  validate :conditions_length, if: :conditions
  validate :identical_to_existing_offer?, if: %i[application_choice course_option]
  validate :ratifying_provider_changed?, if: %i[application_choice course_option]

  def conditions_count
    return if conditions.count <= MAX_CONDITIONS_COUNT

    errors.add(:conditions, :too_many, count: MAX_CONDITIONS_COUNT)
  end

  def conditions_length
    conditions.each_with_index do |condition, index|
      if index.zero?
        errors.add(:conditions, :too_long, index: index + 1, limit: MAX_CONDITION_1_LENGTH) if condition.length > MAX_CONDITION_1_LENGTH
      elsif condition.length > MAX_CONDITION_LENGTH
        errors.add(:conditions, :too_long, index: index + 1, limit: MAX_CONDITION_LENGTH)
      end
    end
  end

  def identical_to_existing_offer?
    if application_choice.current_course_option == course_option && application_choice.offer.conditions_text.sort == conditions.sort
      raise IdenticalOfferError
    end
  end

  def ratifying_provider_changed?
    if application_choice.current_course.ratifying_provider != course_option.course.ratifying_provider
      errors.add(:base, :different_ratifying_provider)
    end
  end
end
