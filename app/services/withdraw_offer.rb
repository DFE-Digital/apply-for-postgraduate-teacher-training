class WithdrawOffer
  include ActiveModel::Validations

  attr_accessor :offer_withdrawal_reason

  validates_presence_of :offer_withdrawal_reason
  validates_length_of :offer_withdrawal_reason, maximum: 255

  def initialize(actor:, application_choice:, offer_withdrawal_reason: nil)
    @auth = ProviderAuthorisation.new(actor: actor)
    @application_choice = application_choice
    @offer_withdrawal_reason = offer_withdrawal_reason
  end

  def save
    return false unless valid?

    @auth.assert_can_make_decisions!(application_choice: @application_choice, course_option_id: @application_choice.offered_option.id)

    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(@application_choice).reject!
      @application_choice.update!(
        offer_withdrawal_reason: @offer_withdrawal_reason,
        offer_withdrawn_at: Time.zone.now,
      )
      SetDeclineByDefault.new(application_form: @application_choice.application_form).call
    end
    true
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end
end
