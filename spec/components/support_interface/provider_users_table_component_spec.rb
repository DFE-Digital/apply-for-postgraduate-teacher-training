require 'rails_helper'

RSpec.describe SupportInterface::ProviderUsersTableComponent do
  subject(:rendered_component) do
    render_inline(
      SupportInterface::ProviderUsersTableComponent.new(provider_users: provider_users),
    ).text
  end

  context 'when the provider user has all fields present' do
    let(:provider_users) do
      [
        create(:provider_user,
               email_address: 'provider@example.com',
               last_signed_in_at: DateTime.new(2019, 12, 1, 10, 45, 0),
               providers: [create(:provider, name: 'The Provider')]),
      ]
    end

    it 'renders all the fields' do
      expect(rendered_component).to include('provider@example.com')
      expect(rendered_component).to include('The Provider')
      expect(rendered_component).to include('1 December 2019 at 10:45am')
    end
  end

  context 'when the provider user has never signed in and was created before 24/12/2019' do
    let(:provider_users) { [create(:provider_user, last_signed_in_at: nil, created_at: Date.new(2019, 12, 23))] }

    it 'shows that we don’t know whether they’ve signed in or not (they’ve never signed in, or they signed in before records began on 24/12/2019)' do
      expect(rendered_component).to include('Unknown (records began 24 December 2019)')
    end
  end

  context 'when the provider user has never signed in and was created after 24/12/2019' do
    let(:provider_users) { [create(:provider_user, last_signed_in_at: nil, created_at: Date.new(2019, 12, 25))] }

    it 'shows that we don’t know whether they’ve signed in or not (they’ve never signed in, or they signed in before records began on 24/12/2019)' do
      expect(rendered_component).to include('Never signed in')
    end
  end

  context 'when there are no provider users' do
    let(:provider_users) { [] }

    it { is_expected.to be_blank }
  end
end
