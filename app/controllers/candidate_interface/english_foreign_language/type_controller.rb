module CandidateInterface
  module EnglishForeignLanguage
    class TypeController < CandidateInterfaceController
      def new
        @type_form = EnglishForeignLanguage::TypeForm.new
      end

      def create
        @type_form = EnglishForeignLanguage::TypeForm.new(type_params)

        if @type_form.save
          redirect_to @type_form.next_form_path
        else
          track_validation_error(@type_form)
          render :new
        end
      end

    private

      def type_params
        strip_whitespace params
          .fetch(:candidate_interface_english_foreign_language_type_form, {})
          .permit(:type)
      end
    end
  end
end
