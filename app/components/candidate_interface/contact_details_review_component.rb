module CandidateInterface
  class ContactDetailsReviewComponent < ViewComponent::Base
    validates :application_form, presence: true

    def initialize(application_form:, editable: true, missing_error: false, submitting_application: false)
      @application_form = application_form
      @contact_details_form = CandidateInterface::ContactDetailsForm.build_from_application(
        @application_form,
      )
      @editable = editable
      @missing_error = missing_error
      @submitting_application = submitting_application
    end

    def contact_details_form_rows
      [phone_number_row, address_row].compact
    end

    def show_missing_banner?
      if @submitting_application && FeatureFlag.active?('mark_every_section_complete')
        !@application_form.contact_details_completed && @editable
      else
        !@contact_details_form.valid?(:base) && !@contact_details_form.valid?(:address) && @editable
      end
    end

  private

    attr_reader :application_form

    def phone_number_row
      {
        key: t('application_form.contact_details.phone_number.label'),
        value: @contact_details_form.phone_number,
        action: t('application_form.contact_details.phone_number.change_action'),
        change_path: Rails.application.routes.url_helpers.candidate_interface_contact_details_edit_base_path,
      }
    end

    def address_row
      change_path =
        if FeatureFlag.active?(:international_addresses)
          Rails.application.routes.url_helpers.candidate_interface_contact_details_edit_address_type_path
        else
          Rails.application.routes.url_helpers.candidate_interface_contact_details_edit_address_path
        end

      {
        key: t('application_form.contact_details.full_address.label'),
        value: full_address,
        action: t('application_form.contact_details.full_address.change_action'),
        change_path: change_path,
      }
    end

    def full_address
      if @contact_details_form.uk?
        [
          @contact_details_form.address_line1,
          @contact_details_form.address_line2,
          @contact_details_form.address_line3,
          @contact_details_form.address_line4,
          @contact_details_form.postcode,
        ]
          .reject(&:blank?)
      else
        [
          @contact_details_form.international_address,
          @contact_details_form.country,
        ]
          .reject(&:blank?)
      end
    end
  end
end
