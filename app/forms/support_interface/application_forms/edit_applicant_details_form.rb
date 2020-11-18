module SupportInterface
  module ApplicationForms
    class EditApplicantDetailsForm
      include ActiveModel::Model

      attr_accessor :phone_number
      attr_reader :application_form

      validates :phone_number, presence: true, phone_number: true

      def initialize(application_form)
        @application_form = application_form

        super(
          phone_number: @application_form.phone_number
        )
      end

      def save!
        @application_form.phone_number = phone_number
        @application_form.save!
      end
    end
  end
end
