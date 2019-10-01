class Candidate < ApplicationRecord
  # Only Devise's :timeoutable module is enabled to handle session expiry
  # Custom Warden strategy is used instead see app/warden/magic_link_token.rb
  devise :timeoutable
  validates :email_address, presence: true, uniqueness: true, length: { maximum: 250 }

  validates :email_address, format: { with: /@/ }

  has_many :application_forms
end
