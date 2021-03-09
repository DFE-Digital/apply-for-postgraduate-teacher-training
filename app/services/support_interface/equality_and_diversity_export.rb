module SupportInterface
  class EqualityAndDiversityExport
    def data_for_export
      data_for_export = application_forms.includes(:application_choices).map do |application_form|
        rejected_application_choices = application_form.application_choices.rejected

        output = {
          'Month' => application_form.submitted_at&.strftime('%B'),
          'Recruitment cycle year' => application_form.recruitment_cycle_year,
          'Sex' => application_form.equality_and_diversity['sex'],
          'Ethnic group' => application_form.equality_and_diversity['ethnic_group'],
          'Ethnic background' => application_form.equality_and_diversity['ethnic_background'],
          'Application status' => I18n.t!("candidate_flow_application_states.#{ProcessState.new(application_form).state}.name"),
          'Application choice 1 unstructured rejection reasons' => rejected_application_choices[0]&.rejection_reason,
          'Application choice 2 unstructured rejection reasons' => rejected_application_choices[1]&.rejection_reason,
          'Application choice 3 unstructured rejection reasons' => rejected_application_choices[2]&.rejection_reason,
          'Application choice 1 structured rejection reasons' => format_structured_rejection_reasons(rejected_application_choices[0]&.structured_rejection_reasons),
          'Application choice 2 structured rejection reasons' => format_structured_rejection_reasons(rejected_application_choices[1]&.structured_rejection_reasons),
          'Application choice 3 structured rejection reasons' => format_structured_rejection_reasons(rejected_application_choices[2]&.structured_rejection_reasons),
        }

        disabilities = application_form.equality_and_diversity['disabilities'].to_a

        disabilities.map.with_index(1) do |disability, index|
          output["Disability #{index}"] = disability
        end

        output
      end

      # The DataExport class creates the header row for us so we need to ensure
      # we sort by longest hash length to ensure all headers appear
      data_for_export.sort_by(&:length).reverse
    end

  private

    def application_forms
      ApplicationForm
        .includes(:application_choices)
        .where.not(equality_and_diversity: nil)
    end
  end
end
