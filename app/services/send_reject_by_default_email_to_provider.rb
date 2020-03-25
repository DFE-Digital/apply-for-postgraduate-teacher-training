class SendRejectByDefaultEmailToProvider
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    return false unless application_choice.rejected?

    application_choice.provider.provider_users.each do |provider_user|
      ProviderMailer.application_rejected_by_default(provider_user, application_choice).deliver_later
    end
  end
end
