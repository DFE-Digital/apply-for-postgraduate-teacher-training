require 'rails_helper'

RSpec.describe AssociatedProvidersPermissionsListComponent do
  let(:ratifying_provider) { create(:provider) }
  let(:training_provider) { create(:provider) }
  let(:provider_relationship_permissions) do
    create(:provider_relationship_permissions,
           ratifying_provider: ratifying_provider,
           training_provider: training_provider,
           training_provider_can_make_decisions: true,
           ratifying_provider_can_make_decisions: true)
  end

  it 'renders ratifying providers the permission also applies to' do
    permission_model = create(:provider_permissions,
                              provider: training_provider,
                              make_decisions: true)
    provider_relationship_permissions
    result = render_inline(described_class.new(permission_model, permission_name: 'make_decisions'))

    expect(result.text).to include('Applies to courses ratified by:')
    expect(result.css('li').text).to include(ratifying_provider.name.to_s)
  end

  it 'renders training providers the permission also applies to' do
    permission_model = create(:provider_permissions,
                              provider: ratifying_provider,
                              make_decisions: true)
    provider_relationship_permissions
    result = render_inline(described_class.new(permission_model, permission_name: 'make_decisions'))

    expect(result.text).to include('Applies to courses run by:')
    expect(result.css('li').text).to include(training_provider.name.to_s)
  end

  it 'does not render associated training providers permissions if there are not any' do
    permission_model = create(:provider_permissions,
                              provider: training_provider,
                              make_decisions: false)
    provider_relationship_permissions
    result = render_inline(described_class.new(permission_model, permission_name: 'make_decisions'))

    expect(result.text).not_to include('Applies to courses run by:')
  end

  it 'does not render associated ratifying providers permissions if there are not any' do
    permission_model = create(:provider_permissions,
                              provider: ratifying_provider,
                              make_decisions: false)
    provider_relationship_permissions
    result = render_inline(described_class.new(permission_model, permission_name: 'make_decisions'))

    expect(result.text).not_to include('Applies to courses ratified by:')
  end
end
