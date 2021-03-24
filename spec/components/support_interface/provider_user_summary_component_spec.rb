require 'rails_helper'

RSpec.describe SupportInterface::ProviderUserSummaryComponent do
  let(:provider_user) do
    create(:provider_user,
           first_name: 'John',
           last_name: 'Smith',
           email_address: 'provider@example.com',
           dfe_sign_in_uid: 'ABC-UID',
           last_signed_in_at: Time.zone.local(2021, 0o3, 15, 10, 45, 0),
           providers: [create(:provider, name: 'The Provider')],
           send_notifications: true)
  end

  subject(:rendered_component) do
    render_inline(
      SupportInterface::ProviderUserSummaryComponent.new(provider_user),
    ).text
  end

  it 'renders all the rows' do
    expect(rendered_component).to include('John')
    expect(rendered_component).to include('Smith')
    expect(rendered_component).to include('provider@example.com')
    expect(rendered_component).to include('ABC-UID')
    expect(rendered_component).to include('15 March 2021')
    expect(rendered_component).to include('The Provider')
  end

  context 'when the configurable provider notification feature flag is on' do
    before { FeatureFlag.activate(:configurable_provider_notifications) }

    it 'renders configurable provider notifications' do
      ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES.each do |notification_preference|
        expect(rendered_component.squish).to include(t("provider_user_notification_preferences.#{notification_preference}.legend"))
      end
    end
  end

  context 'when the configurable provider notification feature flag is off' do
    before { FeatureFlag.deactivate(:configurable_provider_notifications) }

    it 'renders global provider notifications details' do
      ProviderUserNotificationPreferences::NOTIFICATION_PREFERENCES.each do |notification_preference|
        expect(rendered_component.squish).not_to include(t("provider_user_notification_preferences.#{notification_preference}.legend"))
      end
      expect(rendered_component).to include('Yes')
    end
  end
end
