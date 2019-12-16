class ConditionsNotMet
  include ActiveModel::Validations

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save
    ApplicationStateChange.new(@application_choice).conditions_not_met!
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end
end
