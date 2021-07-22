module SupportInterface
  module ApplicationForms
    class EditAddressDetailsForm
      include ActiveModel::Model

      attr_accessor :address_line1, :address_line2, :address_line3, :address_line4,
                    :postcode, :address_type, :country, :audit_comment

      validates :address_line1, :address_line3, :postcode, presence: true, on: :address, if: :uk?

      validates :address_line1, presence: true, on: :address, if: :international?
      validates :postcode, absence: true, on: :address, if: :international?

      validates :address_type, presence: true, on: :address_type
      validates :country, presence: true, on: :address_type, if: :international?

      validates :address_line1, :address_line2, :address_line3, :address_line4,
                length: { maximum: 50 }, on: :address

      validates :postcode, postcode: true, on: :address, if: :uk?
      validates :audit_comment, presence: true, on: :address

      def self.build_from_application_form(application_form)
        new(
          address_line1: application_form.address_line1,
          address_line2: application_form.address_line2,
          address_line3: application_form.address_line3,
          address_line4: application_form.address_line4,
          postcode: application_form.postcode,
          address_type: application_form.address_type || 'GB',
          country: application_form.country,
          audit_comment: application_form.audit_comment,
        )
      end

      def save_address(application_form)
        return false unless valid?(:address)

        attrs = {
          address_line1: address_line1,
          address_line2: address_line2,
          address_line3: address_line3,
          address_line4: address_line4,
          postcode: postcode&.upcase,
          audit_comment: audit_comment,
        }
        attrs[:country] = 'GB' if uk?
        application_form.update(attrs)
      end

      def save_address_type(application_form)
        return false unless valid?(:address_type)

        application_form.update(
          address_type: address_type,
          country: country.presence,
        )
      end

      def uk?
        address_type == 'uk'
      end

      def international?
        address_type == 'international'
      end

      def label_for(attr)
        I18n.t("application_form.contact_details.#{attr}.label.#{address_type}")
      end
    end
  end
end
