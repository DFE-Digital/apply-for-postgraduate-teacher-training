class ChangeOffer
  include ImpersonationAuditHelper

  attr_reader :actor, :application_choice, :course_option, :conditions

  def initialize(actor:,
                 application_choice:,
                 course_option:,
                 conditions: [])
    @actor = actor
    @application_choice = application_choice
    @course_option = course_option
    @conditions = conditions
  end

  def save!
    auth.assert_can_make_decisions!(application_choice: application_choice, course_option: course_option)

    if offer.valid?
      audit(actor) do
        ActiveRecord::Base.transaction do
          ApplicationStateChange.new(application_choice).make_offer!

          application_choice.current_course_option = course_option
          application_choice.offer = { 'conditions' => conditions }
          UpdateOfferConditions.new(application_choice: application_choice, conditions: conditions).call
          application_choice.offer_changed_at = Time.zone.now
          application_choice.save!

          SetDeclineByDefault.new(application_form: application_choice.application_form).call
        end

        CandidateMailer.changed_offer(application_choice).deliver_later
        StateChangeNotifier.call(:change_an_offer, application_choice: application_choice)
      end
    else
      raise ValidationException, offer.errors.map(&:message)
    end
  end

private

  def auth
    @auth ||= ProviderAuthorisation.new(actor: actor)
  end

  def offer
    @offer ||= OfferValidations.new(application_choice: application_choice,
                                    course_option: course_option,
                                    conditions: conditions)
  end
end
