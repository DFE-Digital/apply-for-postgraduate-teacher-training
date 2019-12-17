module SupportInterface
  class ChaseReferenceController < SupportInterfaceController
    def show
      @reference = ApplicationReference.find(params[:reference_id])
      @application_form = @reference.application_form
    end

    def chase
      @reference = ApplicationReference.find(params[:reference_id])
      @application_form = @reference.application_form

      SendChaseEmailToRefereeAndCandidate.call(application_form: @application_form, reference: @reference)

      flash[:success] = t('application_form.referees.chase_success')

      redirect_to support_interface_application_form_path(@application_form)
    end
  end
end
