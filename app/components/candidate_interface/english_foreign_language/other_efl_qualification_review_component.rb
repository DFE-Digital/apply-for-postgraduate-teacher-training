module CandidateInterface
  module EnglishForeignLanguage
    class OtherEflQualificationReviewComponent < ViewComponent::Base
      include EflReviewHelper

      attr_reader :other_qualification

      def initialize(other_qualification)
        @other_qualification = other_qualification
      end

      def ielts_rows
        [
          do_you_have_a_qualification_row(value: 'Yes'),
          type_of_qualification_row(name: other_qualification.name),
          {
            key: 'Score or grade',
            value: other_qualification.grade,
            action: {
              href: candidate_interface_edit_other_efl_qualification_path,
            },
          },
          {
            key: 'Year completed',
            value: other_qualification.award_year,
            action: {
              href: candidate_interface_edit_other_efl_qualification_path,
            },
          },
        ]
      end
    end
  end
end
