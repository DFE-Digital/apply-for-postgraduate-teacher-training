module CandidateInterface
  module DecoupledReferences
    class BaseController < CandidateInterfaceController
      before_action :redirect_to_application_form_if_flag_is_not_active

      def start; end

    private

      def redirect_to_application_form_if_flag_is_not_active
        redirect_to candidate_interface_application_form_path unless FeatureFlag.active?('decoupled_references')
      end

      def set_reference
        @reference = current_candidate.current_application
                                      .application_references
                                      .includes(:application_form)
                                      .find_by(id: params[:id])
      end

      def return_to_path
        case params[:return_to]&.to_sym
        when :review
          candidate_interface_decoupled_references_review_path
        end
      end
    end
  end
end
