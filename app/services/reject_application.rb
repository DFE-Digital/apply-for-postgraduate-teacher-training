class RejectApplication
  Response = Struct.new(:successful?, :application_choice)

  def initialize(application_choice:, rejection:)
    @application_choice = application_choice
    @rejection = rejection
  end

  def call
    ApplicationStateChange.new(@application_choice).reject_application!
    @application_choice.rejection_reason = @rejection[:reason]
    @application_choice.rejected_at = @rejection[:timestamp]

    @application_choice.save
    Response.new(true, @application_choice)
  end
end
