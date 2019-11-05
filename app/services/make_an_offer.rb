class MakeAnOffer
  include ActiveModel::Validations

  MAX_CONDITIONS_COUNT = 20
  MAX_CONDITION_LENGTH = 255

  validate :validate_offer_conditions

  def initialize(application_choice:, offer_conditions:)
    @application_choice = application_choice
    @offer_conditions = offer_conditions
  end

  def save
    return unless valid?

    ApplicationStateChange.new(@application_choice).make_offer!
    @application_choice.offer = { 'conditions' => (@offer_conditions || []) }

    @application_choice.save
  rescue Workflow::NoTransitionAllowed => e
    errors.add(:state, e.message)
    false
  end

private

  def validate_offer_conditions
    return if @offer_conditions.blank?

    unless @offer_conditions.is_a?(Array)
      errors.add(:offer_conditions, 'must be an array')
      return
    end

    errors.add(:offer_conditions, "has over #{MAX_CONDITIONS_COUNT} elements") if @offer_conditions.count > MAX_CONDITIONS_COUNT
    errors.add(:offer_conditions, "has a condition over #{MAX_CONDITION_LENGTH} chars in length") if @offer_conditions.any? { |c| c.length > MAX_CONDITION_LENGTH }
  end
end
