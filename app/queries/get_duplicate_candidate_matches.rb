class GetDuplicateCandidateMatches < ApplicationRecord
  def self.call
    ActiveRecord::Base.connection.exec_query(
      "SELECT DISTINCT application_details.candidate_id, application_details.first_name, application_details.last_name, TRIM(UPPER(application_details.postcode)) postcode, application_details.date_of_birth, email_address
    FROM application_forms application_details
    JOIN(
      SELECT application_forms.last_name, application_forms.date_of_birth, application_forms.postcode
      FROM application_forms
      WHERE application_forms.previous_application_form_id IS NULL
      AND application_forms.submitted_at IS NOT NULL
      GROUP BY application_forms.last_name, application_forms.date_of_birth, application_forms.postcode
      HAVING (count(*) > 1)
    ) duplicate_attributes
    ON application_details.postcode = duplicate_attributes.postcode
    AND application_details.date_of_birth = duplicate_attributes.date_of_birth
    AND application_details.last_name = duplicate_attributes.last_name
    JOIN(
      SELECT candidates.id, candidates.email_address
      FROM candidates
    ) candidate_details
    ON application_details.candidate_id = candidate_details.id
    ORDER BY application_details.date_of_birth",
    ).to_a
  end
end
