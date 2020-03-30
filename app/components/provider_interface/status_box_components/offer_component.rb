module ProviderInterface
  module StatusBoxComponents
    class OfferComponent < ActionView::Component::Base
      include ViewHelper
      attr_reader :application_choice

      def initialize(application_choice:)
        @application_choice = application_choice
      end

      def render?
        application_choice.offer? || \
          raise(ProviderInterface::StatusBoxComponent::ComponentMismatchError)
      end

      def rows
        [
          {
            key: 'Offer made',
            value: application_choice.offered_at.to_s(:govuk_date),
          },
          {
            key: 'Provider',
            value: application_choice.offered_course.provider.name,
            change_path: change_path(:provider), action: 'training provider'
          },
          {
            key: 'Course',
            value: application_choice.offered_course.name_and_code,
            change_path: change_path(:course), action: 'course'
          },
          {
            key: 'Location',
            value: application_choice.offered_site.name_and_address,
            change_path: change_path(:course_option), action: 'location'
          },
        ]
      end

      def paths
        Rails.application.routes.url_helpers
      end

      def change_path(target)
        return nil unless FeatureFlag.active?('provider_change_response')

        case target
        when :provider then paths.provider_interface_application_choice_change_offer_edit_provider_path(application_choice.id)
        when :course then paths.provider_interface_application_choice_change_offer_edit_course_path(application_choice.id)
        when :course_option then paths.provider_interface_application_choice_change_offer_edit_course_option_path(application_choice.id)
        end
      end
    end
  end
end
