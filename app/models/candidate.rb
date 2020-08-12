class Candidate < ApplicationRecord
  include Chased
  # Only Devise's :timeoutable module is enabled to handle session expiry
  # Custom Warden strategy is used instead see app/warden/magic_link_token.rb
  devise :timeoutable
  audited last_signed_in_at: true

  before_validation :downcase_email
  validates :email_address, presence: true,
                            uniqueness: { case_sensitive: false },
                            length: { maximum: 100 },
                            email_address: true

  has_many :application_forms
  belongs_to :course_from_find, class_name: 'Course', optional: true

  def self.for_email(email)
    find_or_initialize_by(email_address: email.downcase) if email
  end

  def current_application
    application_form = application_forms.last
    application_form ||= application_forms.create!
    application_form
  end

  def last_updated_application
    application_forms.max_by(&:updated_at)
  end

  def refresh_magic_link_token!
    magic_link_token = MagicLinkToken.new
    update!(
      magic_link_token: magic_link_token.encrypted,
      magic_link_token_sent_at: Time.zone.now,
    )
    magic_link_token.raw
  end

  def expire_magic_link_token!
    update!(
      magic_link_token: nil,
      magic_link_token_sent_at: nil,
    )
  end

  def encrypted_id
    Encryptor.encrypt(id)
  end

private

  def downcase_email
    email_address.try(:downcase!)
  end
end
