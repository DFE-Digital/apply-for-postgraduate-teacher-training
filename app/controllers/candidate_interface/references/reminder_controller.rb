module CandidateInterface
  module References
    class ReminderController < BaseController
      before_action :set_reference

      def new; end

      def create
        SendReferenceReminder.call(@reference, flash)
        redirect_to candidate_interface_references_review_path
      end
    end
  end
end
