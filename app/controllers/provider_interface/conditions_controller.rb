module ProviderInterface
  class ConditionsController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :redirect_back_if_application_terminated
    before_action :requires_make_decisions_permission

    def edit
      @conditions_form = ConfirmConditionsForm.new
    end

    def confirm_update
      @conditions_form = ConfirmConditionsForm.new(
        conditions_met: params.dig(:provider_interface_confirm_conditions_form, :conditions_met),
      )

      render action: :edit unless @conditions_form.valid?
    end

    def update
      @conditions_form = ConfirmConditionsForm.new(
        conditions_met: params.dig(:provider_interface_confirm_conditions_form, :conditions_met),
      )

      redirect_to action: :edit unless @conditions_form.valid?

      if @conditions_form.conditions_met?
        ConfirmOfferConditions.new(
          actor: current_provider_user,
          application_choice: @application_choice,
        ).save || raise('ConfirmOfferConditions failure')

        flash[:success] = 'Conditions successfully marked as met'
      else
        ConditionsNotMet.new(
          actor: current_provider_user,
          application_choice: @application_choice,
        ).save || raise('ConditionsNotMet failure')

        flash[:success] = 'Conditions successfully marked as not met'
      end

      redirect_to provider_interface_application_choice_path(@application_choice.id)
    end

    def redirect_back_if_application_terminated
      if ApplicationStateChange::TERMINAL_STATES.include?(@application_choice.status.to_sym)
        redirect_back(fallback_location: provider_interface_application_choice_path(@application_choice))
      end
    end
  end
end
