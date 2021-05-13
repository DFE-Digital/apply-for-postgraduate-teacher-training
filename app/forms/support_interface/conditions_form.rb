module SupportInterface
  class ConditionsForm
    class OfferConditionField
      include ActiveModel::Model

      attr_accessor :id, :text

      validates :text, length: { maximum: MakeAnOffer::MAX_CONDITION_LENGTH, too_long: ->(c, _) { "Condition #{c.id + 1} must be %{count} characters or fewer" } }
    end

    include ActiveModel::Model

    attr_accessor :application_choice, :standard_conditions, :further_conditions, :audit_comment

    MIN_FURTHER_CONDITIONS = 4
    MAX_FURTHER_CONDITIONS = MakeAnOffer::MAX_CONDITIONS_COUNT - MakeAnOffer::STANDARD_CONDITIONS.length

    validates :application_choice, presence: true
    validates :audit_comment, presence: true

    def self.build_from_application_choice(application_choice, attrs = {})
      attrs = {
        application_choice: application_choice,
        standard_conditions: standard_conditions_from(application_choice.offer),
        further_conditions: further_conditions_from(application_choice.offer),
      }.merge(attrs)

      new(attrs).tap(&:add_slots_for_new_conditions)
    end

    def self.build_from_params(application_choice, params)
      attrs = {
        standard_conditions: params['standard_conditions'],
        audit_comment: params['audit_comment'],
        further_conditions: params['further_conditions']&.values&.map { |v| v['text'] },
      }

      form = build_from_application_choice(application_choice, attrs)
      form.add_slots_for_new_conditions
      form
    end

    def self.standard_conditions_from(offer)
      return [] if offer.blank?

      conditions = offer['conditions']
      conditions & MakeAnOffer::STANDARD_CONDITIONS
    end

    def self.further_conditions_from(offer)
      return [] if offer.blank?

      conditions = offer['conditions']
      conditions - MakeAnOffer::STANDARD_CONDITIONS
    end

    def add_slots_for_new_conditions
      further_condition_count = (further_conditions&.reject(&:blank?)&.count || 0)
      number_of_conditions_to_display = [
        [MIN_FURTHER_CONDITIONS, further_condition_count + 1].max,
        MAX_FURTHER_CONDITIONS,
      ].min

      self.further_conditions = number_of_conditions_to_display.times.map do |index|
        existing_value = further_conditions && further_conditions[index]
        existing_value.presence || ''
      end
    end

    def further_condition_models
      @further_condition_models ||= further_conditions.map.with_index do |further_condition, index|
        OfferConditionField.new(id: index, text: further_condition)
      end
    end

    def save
      return false unless valid?

      application_choice.update(
        offer: { conditions: (standard_conditions + further_conditions).reject(&:blank?) },
        audit_comment: audit_comment,
      )
    end
  end
end
