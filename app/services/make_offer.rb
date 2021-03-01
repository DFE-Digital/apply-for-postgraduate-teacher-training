class MakeOffer
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
    make_an_offer = MakeAnOffer.new(actor: actor,
                                    application_choice: application_choice,
                                    course_option: course_option,
                                    offer_conditions: conditions)
    make_an_offer.save

    if make_an_offer.errors[:base].include?(MakeAnOffer::STATE_TRANSITION_ERROR)
      ApplicationStateChange.new(application_choice).make_offer!
    end
  end
end
