class ApplicationVolunteeringExperience < ApplicationExperience
  belongs_to :application_form, touch: true

  audited associated_with: :application_form
end
