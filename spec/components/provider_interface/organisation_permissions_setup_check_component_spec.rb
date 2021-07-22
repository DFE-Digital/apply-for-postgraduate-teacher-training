require 'rails_helper'

RSpec.describe ProviderInterface::OrganisationPermissionsSetupCheckComponent do
  let(:render) do
    render_inline(
      described_class.new(
        relationships: relationships,
        current_provider_user: current_provider_user,
      ),
    )
  end

  context 'when there are relationships from multiple providers' do
    let(:relationships) { create_list(:provider_relationship_permissions, 2) }
    let(:current_provider_user) { create(:provider_user, providers: relationships.map(&:training_provider)) }

    it 'renders each provider name per relationship group' do
      sorted_main_provider_names = relationships.map(&:training_provider).map(&:name).sort
      expect(render.css('h2.govuk-heading-m')[0].text.squish).to eq(sorted_main_provider_names.first)
      expect(render.css('h2.govuk-heading-m')[1].text.squish).to eq(sorted_main_provider_names.second)
    end
  end

  context 'when there are only relationships from a single provider' do
    let(:current_provider_user) { create(:provider_user, :with_provider) }
    let(:relationships) { create_list(:provider_relationship_permissions, 2, training_provider:current_provider_user.providers.first) }

    it 'should not render the provider name' do
      expect(render.css('h2.govuk-heading-m')).to be_empty
    end
  end
end
