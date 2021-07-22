module CandidateInterface
  class ContactDetailsForm
    include ActiveModel::Model

    attr_accessor :phone_number, :address_line1, :address_line2, :address_line3,
                  :address_line4, :postcode, :address_type, :country

    validates :address_line1, :address_line3, :postcode, presence: true, on: :address, if: :uk?
    validates :address_line1, presence: true, on: :address, if: :international?
    validates :address_type, presence: true, on: :address_type
    validates :country, presence: true, on: :address_type, if: :international?

    validates :address_line1, :address_line2, :address_line3, :address_line4,
              length: { maximum: 50 }, on: :address

    validates :phone_number, length: { maximum: 50 }, phone_number: true, on: :base

    validates :postcode, postcode: true, on: :address, if: :uk?

    def self.build_from_application(application_form)
      new(
        phone_number: application_form.phone_number,
        address_line1: application_form.address_line1,
        address_line2: application_form.address_line2,
        address_line3: application_form.address_line3,
        address_line4: application_form.address_line4,
        postcode: application_form.postcode,
        address_type: application_form.address_type || 'GB',
        country: application_form.country,
      )
    end

    def save_base(application_form)
      return false unless valid?(:base)

      application_form.update(phone_number: phone_number)
    end

    def save_address(application_form)
      return false unless valid?(:address)

      attrs = {
        address_line1: address_line1,
        address_line2: address_line2,
        address_line3: address_line3,
        address_line4: address_line4,
        postcode: postcode&.upcase,
      }
      attrs[:country] = 'GB' if uk?
      application_form.update(attrs)
    end

    def save_address_type(application_form)
      return false unless valid?(:address_type)

      application_form.update(
        address_type: address_type,
        country: country,
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
