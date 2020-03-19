class Email < ApplicationRecord
  # Note that most, but not all, emails that we send are in regards to an
  # application form. For sign-ups and sign-ins application_form will be nil.
  belongs_to :application_form, optional: true

  enum delivery_status: {
    # Email predates implementation of GOV.UK Notify callback
    not_tracked: 'not_tracked',

    # Email has been sent, but we're waiting on callback from GOV.UK Notify
    pending: 'pending',

    # DEPRECATED - do not use
    unknown: 'unknown',

    # Mirrors the state that we get back from GOV.UK Notify
    #
    # https://docs.notifications.service.gov.uk/rest-api.html#set-up-callbacks
    delivered: 'delivered',
    permanent_failure: 'permanent_failure',
    temporary_failure: 'temporary_failure',
    technical_failure: 'technical_failure',
  }

  def humanised_email_type
    "#{mail_template.humanize} (#{mailer.humanize})"
  end
end
