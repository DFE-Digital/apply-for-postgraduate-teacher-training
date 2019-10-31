module SupportViewHelper
  def audit_entry_label(audit)
    "#{audit_entry_event_label(audit)} - #{audit_entry_user_label(audit)}"
  end

  def format_audit_value(value)
    if value.is_a? Array
      "#{value[0] || 'nil'} → #{value[1] || 'nil'}"
    else
      value.to_s
    end
  end

  def audit_value_present?(value)
    if value.is_a? Array
      value.any?(&:present?)
    else
      value.present?
    end
  end

private

  def audit_entry_event_label(audit)
    "#{audit.action.capitalize} #{audit.auditable_type.titlecase}"
  end

  def audit_entry_user_label(audit)
    if audit.user.is_a? Candidate
      "#{audit.user.email_address} (Candidate)"
    elsif audit.user.is_a? VendorApiUser
      "#{audit.user.email_address} (Vendor API)"
    else
      '(Unknown User)'
    end
  end
end
