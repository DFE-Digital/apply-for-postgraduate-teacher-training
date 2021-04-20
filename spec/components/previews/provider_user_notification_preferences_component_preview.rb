class ProviderUserNotificationPreferencesComponentPreview < ViewComponent::Preview
  layout 'previews/provider'

  def notification_preferences
    render ProviderUserNotificationPreferencesComponent.new(
      FactoryBot.build(:provider_user_notification_preferences),
      form_path: '/404',
    )
  end
end
