class ReceiveReference
  attr_reader :referee_email
  attr_reader :feedback

  include ActiveModel::Validations

  validates_presence_of :referee_email
  validate :referee_must_exist_on_application_form

  def initialize(application_form:, referee_email:, feedback:)
    @application_form = application_form
    @referee_email = referee_email
    @feedback = feedback
  end

  def save
    return unless valid?

    ActiveRecord::Base.transaction do
      @application_form
        .references
        .find { |reference| reference.email_address == @referee_email }
        .update!(feedback: @feedback)

      if @application_form.references_complete?
        @application_form.application_choices.each do |application_choice|
          ApplicationStateChange.new(application_choice).references_complete!
        end
      end
    end
  rescue Workflow::NoTransitionAllowed => e
    errors.add(:state, e.message)
    false
  end

private

  def referee_must_exist_on_application_form
    if @application_form.references.where(email_address: @referee_email).empty?
      errors.add(:referee_email, 'does not match any of the provided referees')
    end
  end
end
