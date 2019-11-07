class ApplicationQualification < ApplicationRecord
  belongs_to :application_form

  scope :degrees, -> { where level: 'degree' }
  scope :other, -> { where level: 'other' }

  enum level: {
    degree: 'degree',
    gcse: 'gcse',
    other: 'other',
  }
end
