class OfferCondition < ApplicationRecord

  STANDARD_CONDITIONS = ['Fitness to train to teach check', 'Disclosure and Barring Service (DBS) check'].freeze

  belongs_to :offer
  has_one :application_choice, through: :offer

  audited associated_with: :application_choice

  enum status: {
    pending: 'pending',
    met: 'met',
    unmet: 'unmet',
  }
end
