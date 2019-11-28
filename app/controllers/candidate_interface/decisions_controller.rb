module CandidateInterface
  class DecisionsController < CandidateInterfaceController
    before_action :set_application_choice

    def offer
      @respond_to_offer = CandidateInterface::RespondToOfferForm.new
    end

    def respond_to_offer
      response = params.dig(:candidate_interface_respond_to_offer_form, :response)

      @respond_to_offer = CandidateInterface::RespondToOfferForm.new(response: response)

      if !@respond_to_offer.valid?
        render :offer
      elsif @respond_to_offer.decline?
        redirect_to candidate_interface_decline_offer_path(@application_choice)
      elsif @respond_to_offer.accept?
        redirect_to candidate_interface_accept_offer_path(@application_choice)
      end
    end

    def decline_offer; end

    def actually_decline
      decline = DeclineOffer.new(application_choice: @application_choice.reload)

      if decline.save
        redirect_to candidate_interface_application_complete_path
      else
        raise decline.errors.full_messages.to_s
      end
    end

    def accept_offer; end

    def actually_accept
      accept = AcceptOffer.new(application_choice: @application_choice.reload)

      if accept.save
        redirect_to candidate_interface_application_complete_path
      else
        raise accept.errors.full_messages.to_s
      end
    end

    def withdraw; end

  private

    def set_application_choice
      @application_choice = current_candidate.current_application.application_choices.find(params[:id])
    end
  end
end
