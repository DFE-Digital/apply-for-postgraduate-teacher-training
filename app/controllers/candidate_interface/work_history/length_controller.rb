module CandidateInterface
  class WorkHistory::LengthController < CandidateInterfaceController
    def show
      @work_details_form = WorkHistoryForm.new
    end

    def submit
      @work_details_form = WorkHistoryForm.new(work_history_form_params)

      if @work_details_form.valid?
        redirect_to candidate_interface_work_history_new_path
      else
        render :length
      end
    end

  private

    def work_history_form_params
      return nil unless params.has_key?(:candidate_interface_work_history_form)

      params.require(:candidate_interface_work_history_form).permit(
        :work_history,
      )
    end
  end
end
