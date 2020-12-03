class ActivityLogEvent
  attr_reader :audit
  delegate :created_at, to: :audit

  def initialize(audit:)
    @audit = audit
  end

  def changes
    audit.audited_changes
  end

  def user_full_name
    audit.user.try(:full_name) || audit.user.try(:display_name)
  end

  def candidate_full_name
    audit.auditable.try(:application_form)&.full_name
  end

  def application_status_at_event
    return unless audit.auditable.respond_to?(:status)

    changes['status'].second if changes.key?('status')
  end
end
