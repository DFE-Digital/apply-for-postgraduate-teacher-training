module VendorAPI
  class DecisionsController < VendorAPIController
    before_action :validate_metadata!

    def make_offer
      course_data = params.dig(:data, :course)

      course_option = if course_data.present?
                        GetCourseOptionFromCodes.new(
                          provider_code: course_data[:provider_code],
                          course_code: course_data[:course_code],
                          recruitment_cycle_year: course_data[:recruitment_cycle_year],
                          study_mode: course_data[:study_mode],
                          site_code: course_data[:site_code],
                        ).call
                      else
                        application_choice.course_option
                      end

      if FeatureFlag.active?(:updated_offer_flow)
        offer_service = if application_choice.offer?
                          ChangeOffer.new(offer_params(application_choice, course_option))
                        else
                          MakeOffer.new(offer_params(application_choice, course_option))
                        end

        respond_to_decision(offer_service)
      elsif application_choice.offer?
        change_offer = ChangeAnOffer.new(
          actor: audit_user,
          application_choice: application_choice,
          course_option: course_option,
          offer_conditions: params.dig(:data, :conditions),
        )

        if change_offer.identical_to_existing_offer?
          # noop - allow multiple POSTs (effectively PUTs) of the same offer
          # to support vendors who don’t trust the network
          render_application
        else
          respond_to_decision(change_offer)
        end
      else
        make_offer = MakeAnOffer.new(
          actor: audit_user,
          application_choice: application_choice,
          course_option: course_option,
          offer_conditions: params.dig(:data, :conditions),
        )

        respond_to_decision(make_offer)
      end
    end

    def confirm_conditions_met
      decision = ConfirmOfferConditions.new(
        actor: audit_user,
        application_choice: application_choice,
      )

      respond_to_decision(decision)
    end

    def conditions_not_met
      decision = ConditionsNotMet.new(
        actor: audit_user,
        application_choice: application_choice,
      )

      respond_to_decision(decision)
    end

    def reject
      decision =
        if application_choice.offer?
          WithdrawOffer.new(
            actor: audit_user,
            application_choice: application_choice,
            offer_withdrawal_reason: params.dig(:data, :reason),
          )
        else
          RejectApplication.new(
            actor: audit_user,
            application_choice: application_choice,
            rejection_reason: params.dig(:data, :reason),
          )
        end

      respond_to_decision(decision)
    end

    # This method is a no-op since we removed enrolment from the app
    def confirm_enrolment
      render_application

      e = Exception.new("Vendor API token ##{@current_vendor_api_token.id} tried to enrol application choice ##{application_choice.id}, but enrolment is not supported")
      Raven.capture_exception(e)
    end

  private

    def application_choice
      @application_choice ||= GetApplicationChoicesForProviders.call(providers: current_provider, vendor_api: true).find(params[:application_id])
    end

    def render_application
      render json: { data: SingleApplicationPresenter.new(application_choice).as_json }
    end

    def respond_to_decision(decision)
      if FeatureFlag.active?(:updated_offer_flow) && [MakeOffer, ChangeOffer].include?(decision.class)
        decision.save!
        render_application
      elsif decision.save
        render_application
      else
        render_validation_errors(decision.errors)
      end
    rescue IdenticalOfferError
      render_application
    rescue ValidationException => e
      render status: :unprocessable_entity, json: e.as_json
    rescue Workflow::NoTransitionAllowed
      render status: :unprocessable_entity, json: {
        errors: [
          error: 'StateTransitionError',
          message: 'The application is not ready for that action',
        ],
      }
    rescue ProviderAuthorisation::NotAuthorisedError => e
      render status: :unprocessable_entity, json: {
        errors: [
          {
            error: 'NotAuthorisedError',
            message: e.message,
          },
        ],
      }
    end

    # Takes errors from ActiveModel::Validations and render them in the API response
    def render_validation_errors(errors)
      error_responses = errors.full_messages.map { |message| { error: 'ValidationError', message: message } }
      render status: :unprocessable_entity, json: { errors: error_responses }
    end

    def offer_params(application_choice, course_option)
      {
        actor: audit_user,
        application_choice: application_choice,
        course_option: course_option,
        conditions: conditions_params,
      }
    end

    def conditions_params
      params.require(:data).permit(conditions: [])[:conditions] || []
    end
  end
end
