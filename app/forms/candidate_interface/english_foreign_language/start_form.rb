module CandidateInterface
  module EnglishForeignLanguage
    class StartForm
      include ActiveModel::Model
      include Rails.application.routes.url_helpers

      attr_accessor :qualification_status, :no_qualification_details, :application_form

      validates :qualification_status, presence: true
      validates :no_qualification_details, word_count: { maximum: 200 }

      def save
        return false unless valid?

        raise_error_unless_application_form

        if qualification_status == 'has_qualification'
          true
        else
          UpdateEnglishProficiency.new(
            application_form,
            qualification_status: qualification_status,
            no_qualification_details: no_qualification_details,
          ).call
        end
      end

      def next_path
        if qualification_status == 'has_qualification'
          candidate_interface_english_foreign_language_type_path
        else
          candidate_interface_english_foreign_language_review_path
        end
      end

    private

      def raise_error_unless_application_form
        if application_form.blank?
          raise MissingApplicationFormError
        end
      end
    end
  end
end
