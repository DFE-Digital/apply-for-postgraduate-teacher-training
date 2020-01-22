class ProcessNotifyCallback
  def initialize(notify_reference:, status:)
    @environment, @email_type, @reference_id = notify_reference.split('-')
    @status = status
    @not_found = false
  end

  def call
    return unless same_environment? && reference_request_email? && permanent_failure_status?

    ActiveRecord::Base.transaction do
      reference = ApplicationReference.find(@reference_id)

      reference.update!(feedback_status: 'email_bounced')

      SendNewRefereeRequestEmail.call(
        application_form: reference.application_form,
        reference: reference,
        reason: :email_bounced,
      )
    end
  rescue ActiveRecord::RecordNotFound
    @not_found = true
  end

  def not_found?
    @not_found
  end

private

  def same_environment?
    @environment == HostingEnvironment.environment_name
  end

  def reference_request_email?
    @email_type == 'reference_request'
  end

  def permanent_failure_status?
    @status == 'permanent-failure'
  end
end
