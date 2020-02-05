module ProviderInterface
  class DecisionsController < ProviderInterfaceController
    before_action :set_application_choice

    def respond
      @pick_response_form = PickResponseForm.new
    end

    def submit_response
      @pick_response_form = PickResponseForm.new(decision: params.dig(:provider_interface_pick_response_form, :decision))
      render action: :respond if !@pick_response_form.valid?

      if @pick_response_form.decision == 'offer'
        redirect_to action: :new_offer
      elsif @pick_response_form.decision == 'reject'
        redirect_to action: :new_reject
      end
    end

    def new_offer
      @application_offer = MakeAnOffer.new(application_choice: @application_choice)
    end

    def confirm_offer
      @application_offer = MakeAnOffer.new(
        application_choice: @application_choice,
        standard_conditions: make_an_offer_params[:standard_conditions],
        further_conditions: make_an_offer_params.permit(
          :further_conditions0,
          :further_conditions1,
          :further_conditions2,
          :further_conditions3,
        ).to_h,
      )
      render action: :new_offer if !@application_offer.valid?
    end

    def create_offer
      offer_conditions_array = JSON.parse(params.dig(:offer_conditions))

      @application_offer = MakeAnOffer.new(
        application_choice: @application_choice,
        offer_conditions: offer_conditions_array,
      )

      if @application_offer.save
        flash[:success] = 'Application status changed to ‘Offer made’'
        redirect_to provider_interface_application_choice_path(
          application_choice_id: @application_choice.id,
        )
      else
        render action: :new_offer
      end
    end

    def new_reject
      @reject_application = RejectApplication.new(application_choice: @application_choice)
    end

    def confirm_reject
      @reject_application = RejectApplication.new(
        application_choice: @application_choice,
        rejection_reason: params.dig(:reject_application, :rejection_reason),
      )
      render action: :new_reject if !@reject_application.valid?
    end

    def create_reject
      @reject_application = RejectApplication.new(
        application_choice: @application_choice,
        rejection_reason: params.dig(:reject_application, :rejection_reason),
      )
      if @reject_application.save
        flash[:success] = 'Application status changed to ‘Rejected’'
        redirect_to provider_interface_application_choice_path(
          application_choice_id: @application_choice.id,
        )
      else
        render action: :new_reject
      end
    end

    def new_edit_response
      @edit_response = EditResponseForm.new
    end

    def edit_response
      raise unless FeatureFlag.active?('provider_change_response')

      @edit_response = EditResponseForm.new(
        edit_response_type: params.dig(:provider_interface_edit_response_form, :edit_response_type),
      )
      if @edit_response.valid?
        redirect_to provider_interface_application_choice_new_withdraw_offer_path(
          application_choice_id: @application_choice.id,
        )
      else
        render action: :new_edit_response
      end
    end

    def new_withdraw_offer
      @withdraw_offer = WithdrawOfferForm.new
    end

    def confirm_withdraw_offer
      @withdraw_offer = WithdrawOfferForm.new(
        reason: params.dig(:provider_interface_withdraw_offer_form, :reason),
      )
      if !@withdraw_offer.valid?
        render action: :new_withdraw_offer
      end
    end

    def withdraw_offer
      raise unless FeatureFlag.active?('provider_change_response')

      @withdraw_offer = WithdrawOfferForm.new(
        reason: params.dig(:provider_interface_withdraw_offer_form, :reason),
      )
      if WithdrawOffer.new(
        application_choice: @application_choice,
        offer_withdrawal_reason: @withdraw_offer.reason,
      ).save
        flash[:success] = 'Application status changed to ‘Offer withdrawn’'
        redirect_to provider_interface_application_choice_path(
          application_choice_id: @application_choice.id,
        )
      else
        render action: :new_withdraw_offer
      end
    end

  private

    def set_application_choice
      @application_choice = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .find(params[:application_choice_id])
    end

    def make_an_offer_params
      params.require(:make_an_offer)
    end
  end
end
