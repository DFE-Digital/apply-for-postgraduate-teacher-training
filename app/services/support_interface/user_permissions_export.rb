module SupportInterface
  class UserPermissionsExport
    def data_for_export
      data = Audited::Audit
        .joins('JOIN provider_users_providers pup1 ON audits.auditable_id = pup1.id')
        .joins('JOIN provider_users ON pup1.provider_user_id = provider_users.id')
        .joins('LEFT JOIN provider_users_providers pup2 ON audits.user_id = pup2.provider_user_id')
        .joins('LEFT JOIN providers ON pup2.provider_id = providers.id')
        .where(auditable_type: 'ProviderPermissions')
        .where(action: %w[create update])
        .where(permissions_clauses)
        .pluck(
          'audits.created_at',
          'audits.user_id',
          'audits.username',
          'providers.code',
          'providers.name',
          Arel.sql("CONCAT(provider_users.first_name, ' ' , provider_users.last_name)"),
          'audits.audited_changes',
        )

      data.map do |row|
        audited_changes = row.pop
        row << permissions_changes(audited_changes)
        row << permissions_changes(audited_changes, false)
        Hash[labels.zip(row)]
      end
    end

  private

    def labels
      [
        'Date',
        'User ID',
        'User making change',
        'Provider code', 'Provider',
        'User whose permission(s) have changed',
        'Permissions added',
        'Permissions removed'
      ]
    end

    def permissions_changes(audited_changes, enabled = true)
      changes = audited_changes.select do |k, v|
        ProviderPermissions::VALID_PERMISSIONS.map(&:to_s).include?(k) &&
          (v.is_a?(Array) ? v.last == enabled : v == enabled)
      end

      changes.keys.sort.join(', ')
    end

    def permissions_clauses
      clauses = ProviderPermissions::VALID_PERMISSIONS.map do |p|
        "jsonb_exists(audits.audited_changes, '#{p}')"
      end

      clauses.join(' OR ')
    end
  end
end
