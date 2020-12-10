module CandidateInterface
  module EnglishForeignLanguage
    class ReviewController < CandidateInterfaceController
      include EflRootConcern

      before_action :check_for_english_proficiency

      def show
        @component_instance = ChooseEflReviewComponent.call(english_proficiency)
      end

      def complete
        current_application.update!(completion_params)
        redirect_to candidate_interface_application_form_path
      end

    private

      def english_proficiency
        current_application.english_proficiency
      end

      def check_for_english_proficiency
        if english_proficiency.blank?
          redirect_to_efl_root
        end
      end

      def completion_params
        strip_whitespace params
          .require(:application_form)
          .permit(:efl_completed)
      end
    end
  end
end
