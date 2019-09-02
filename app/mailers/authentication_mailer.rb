class AuthenticationMailer < ApplicationMailer
  def sign_up_email(to:, token:)
    @magic_link = "#{new_personal_details_url}?token=#{token}"

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: to,
              subject: t('authentication.sign_up.email.subject'))
  end
end
