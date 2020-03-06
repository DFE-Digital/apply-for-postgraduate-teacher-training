require 'rails_helper'

RSpec.describe SupportInterface::ApplicationChoicesExport, with_audited: true do
  describe '#application_choices' do
    it 'returns submitted application choices with timings' do
      unsubmitted_form = create(:application_form)
      create(:application_choice, status: :unsubmitted, application_form: unsubmitted_form)
      submitted_form = create(:completed_application_form, application_choices_count: 2)

      choices = described_class.new.application_choices
      expect(choices.size).to eq(2)

      expect(choices).to contain_exactly(
        {
          support_reference: submitted_form.support_reference,
          submitted_at: submitted_form.submitted_at,
          choice_id: submitted_form.application_choices[0].id,
          provider_code: submitted_form.application_choices[0].course.provider.code,
          course_code: submitted_form.application_choices[0].course.code,
        },
        {
          support_reference: submitted_form.support_reference,
          submitted_at: submitted_form.submitted_at,
          choice_id: submitted_form.application_choices[1].id,
          provider_code: submitted_form.application_choices[1].course.provider.code,
          course_code: submitted_form.application_choices[1].course.code,
        },
      )
    end
  end
end
