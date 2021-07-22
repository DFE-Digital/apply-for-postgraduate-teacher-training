require 'rails_helper'

RSpec.describe ProviderRelationshipPermissions do
  let(:setup_at) { Time.zone.now }

  describe 'validations' do
    subject(:permissions) do
      described_class.new(
        ratifying_provider: build_stubbed(:provider),
        training_provider: build_stubbed(:provider),
        ratifying_provider_can_view_safeguarding_information: true,
        ratifying_provider_can_view_diversity_information: true,
        setup_at: setup_at,
      )
    end

    it 'ensures at least one permission in each pair is active' do
      expect(permissions.valid?).to be false
      expect(permissions.errors.attribute_names).to eq(%i[make_decisions])
    end

    context 'when permissions have not been set up' do
      let(:setup_at) { nil }

      it 'skips validation' do
        expect(permissions.valid?).to be true
      end

      context 'when the :setup context is used' do
        it 'ensures at least one permission in each pair is active' do
          expect(permissions.valid?(:setup)).to be false
          expect(permissions.errors.attribute_names).to eq(%i[make_decisions])
        end
      end
    end

    context 'when at least one permission in each pair is active' do
      it 'is a valid set of permissions' do
        permissions.training_provider_can_make_decisions = true

        expect(permissions.valid?).to be true
      end
    end
  end

  describe 'auditing', with_audited: true do
    let(:training_provider) { create(:provider) }
    let(:ratifying_provider) { create(:provider) }
    let(:provider_relationship_permissions) do
      create(:provider_relationship_permissions,
             training_provider: training_provider,
             ratifying_provider: ratifying_provider,
             setup_at: setup_at)
    end

    before do
      provider_relationship_permissions
    end

    it 'creates audit entries' do
      expect {
        provider_relationship_permissions.update!(ratifying_provider_can_make_decisions: true)
      }.to change { training_provider.associated_audits.count }.by(1)
    end

    it 'creates an associated object in each audit record' do
      provider_relationship_permissions.update!(training_provider_can_make_decisions: true)

      expect(training_provider.associated_audits.last.auditable).to eq provider_relationship_permissions
      expect(provider_relationship_permissions.audits.last.associated).to eq(training_provider)
    end
  end

  describe '#all_relationships_for_providers' do
    let(:training_provider) { create(:provider) }
    let(:ratifying_provider) { create(:provider) }
    let!(:random_relationship) { create(:provider_relationship_permissions) }
    let!(:relationship) do
      create(
        :provider_relationship_permissions,
        training_provider: training_provider,
        ratifying_provider: ratifying_provider,
      )
    end

    it 'includes training providers' do
      expect(described_class.all_relationships_for_providers([training_provider])).to eq([relationship])
    end

    it 'includes ratifying providers' do
      expect(described_class.all_relationships_for_providers([ratifying_provider])).to eq([relationship])
    end

    it 'does not include duplicates' do
      expect(described_class.all_relationships_for_providers([training_provider, ratifying_provider])).to eq([relationship])
    end
  end
end
