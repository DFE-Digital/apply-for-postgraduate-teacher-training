class Reference < ApplicationRecord
  validates :email_address, presence: true, length: { maximum: 100 }
  belongs_to :application_form
end
