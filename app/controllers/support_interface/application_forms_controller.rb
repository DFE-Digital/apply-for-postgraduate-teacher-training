module SupportInterface
  class ApplicationFormsController < SupportInterfaceController
    def index
      application_forms = ApplicationForm.includes(:application_choices)

      @application_forms = application_forms.map do |application_choice|
        ApplicationFormPresenter.new(application_choice)
      end
    end

    def show
      application_form = ApplicationForm
        .includes(:application_choices)
        .find(params[:application_form_id])

      @application_form = ApplicationFormPresenter.new(application_form)
    end
  end
end
