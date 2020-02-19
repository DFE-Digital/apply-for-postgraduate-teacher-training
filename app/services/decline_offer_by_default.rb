class DeclineOfferByDefault
  attr_accessor :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def call
    ActiveRecord::Base.transaction do
      application_form.application_choices.offer.each do |application_choice|
        application_choice.update!(declined_by_default: true, declined_at: Time.zone.now)
        ApplicationStateChange.new(application_choice).decline_by_default!
      end
    end
  end
end
