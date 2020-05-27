module ProviderInterface
  class ChangeOfferPreview < ViewComponent::Preview
    def existing_offer_start_at_1_provider(provider_interface_change_offer_form: nil)
      initial_step :provider
      set_application_choice application_choice_with_offer

      form = submitted_form(provider_interface_change_offer_form) || new_form
      render_with form
    end

    def existing_offer_start_at_2_course(provider_interface_change_offer_form: nil)
      initial_step :course
      set_application_choice application_choice_with_offer

      form = submitted_form(provider_interface_change_offer_form) || new_form
      render_with form
    end

    def existing_offer_start_at_3_location(provider_interface_change_offer_form: nil)
      initial_step :course_option
      set_application_choice application_choice_with_offer

      form = submitted_form(provider_interface_change_offer_form) || new_form
      render_with form
    end

    def existing_offer_start_at_confirm_change(provider_interface_change_offer_form: nil)
      initial_step :confirm
      set_application_choice application_choice_with_offer

      form = submitted_form(provider_interface_change_offer_form)
      form ||= new_form(new_course_option: pick_different_option)
      render_with form
    end

    def new_offer_start_at_1_provider(provider_interface_change_offer_form: nil)
      initial_step :provider
      set_application_choice application_choice_awaiting_decision

      form = submitted_form(provider_interface_change_offer_form) || new_form
      render_with form
    end

    def new_offer_start_at_2_course(provider_interface_change_offer_form: nil)
      initial_step :course
      set_application_choice application_choice_awaiting_decision

      form = submitted_form(provider_interface_change_offer_form) || new_form
      render_with form
    end

    def new_offer_start_at_3_location(provider_interface_change_offer_form: nil)
      initial_step :course_option
      set_application_choice application_choice_awaiting_decision

      form = submitted_form(provider_interface_change_offer_form) || new_form
      render_with form
    end

  private

    def render_with(form)
      render_component(
        ProviderInterface::ChangeOfferComponent,
        form: form,
        completion_url: '/rails/view_components',
      )
    end

    def provider_user
      @provider_user ||= ProviderUser.find_by dfe_sign_in_uid: 'dev-support'
    end

    def available_providers
      provider_user.providers
    end

    def available_choices
      provider_user.providers.first.application_choices
    end

    def initial_step(step)
      @step = step
    end

    def set_application_choice(application_choice)
      @application_choice = application_choice
    end

    def application_choice_awaiting_decision
      available_choices.where(status: :awaiting_provider_decision).order('created_at').first
    end

    def application_choice_with_offer
      available_choices.where(status: :offer).order('created_at').first
    end

    def submitted_form(hash)
      if hash
        # in this context, hash keys and values are strings
        hash['step'] = hash['step'].to_sym
        hash['application_choice'] = @application_choice
        hash['provider_id'] = hash['provider_id'].to_i if hash['provider_id']
        hash['course_id'] = hash['course_id'].to_i if hash['course_id']
        hash['course_option_id'] = hash['course_option_id'].to_i if hash['course_option_id']
        ProviderInterface::ChangeOfferForm.new(hash)
      end
    end

    def new_form(new_course_option: nil)
      application_choice ||= @application_choice
      if new_course_option
        provider_id = new_course_option.provider.id
        course_id = new_course_option.course.id
        course_option_id = new_course_option.id
      else
        provider_id = application_choice.offered_course.provider.id
        course_id = application_choice.offered_course.id
        course_option_id = application_choice.offered_option.id
      end
      ProviderInterface::ChangeOfferForm.new(
        application_choice: application_choice,
        step: @step,
        provider_id: provider_id,
        course_id: course_id,
        course_option_id: course_option_id,
      )
    end

    def pick_different_option
      new_provider = available_providers.sample
      new_course = new_provider.courses.where(
        open_on_apply: true,
        recruitment_cycle_year: @application_choice.offered_course.recruitment_cycle_year,
      ).sample
      new_course.course_options.sample
    end

    def render_component(component_to_render, form:, completion_url:)
      if form.application_choice
        render component_to_render.new(
          change_offer_form: form,
          providers: available_providers,
          completion_url: completion_url,
        )
      else
        render template: 'support_interface/docs/missing_test_data'
      end
    end
  end
end
