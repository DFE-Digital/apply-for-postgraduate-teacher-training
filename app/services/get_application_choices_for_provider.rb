class GetApplicationChoicesForProvider
  def self.call(provider:)
    states_not_visible_to_provider = %i[unsubmitted awaiting_references application_complete]

    ApplicationChoice
    .for_provider(provider.code)
    .where('status NOT IN (?)', states_not_visible_to_provider)
  end
end
