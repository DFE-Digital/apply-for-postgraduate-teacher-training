module SupportInterface
  class ApplicationChoiceComponent < ViewComponent::Base
    include ViewHelper
    include APIDocsHelper

    attr_reader :application_choice

    def initialize(application_choice)
      @application_choice = application_choice
    end

    def rows
      rows = [
        { key: 'Status', value: render(SupportInterface::ApplicationStatusTagComponent.new(status: application_choice.status)) },
      ]

      if application_choice.offer?
        rows << { key: 'Offer made at', value: application_choice.offered_at.to_s(:govuk_date_and_time) }
        rows << { key: 'Decline by default at', value: application_choice.decline_by_default_at.to_s(:govuk_date_and_time) } if application_choice.decline_by_default_at
      end

      if application_choice.different_offer?
        rows << { key: 'Course candidate applied for', value: render(CourseOptionDetailsComponent.new(course_option: application_choice.course_option)) }
        rows << { key: 'Course offered by provider', value: render(CourseOptionDetailsComponent.new(course_option: application_choice.offered_course_option)) }
      else
        rows << { key: 'Course', value: render(CourseOptionDetailsComponent.new(course_option: application_choice.course_option)) }
      end

      if application_choice.rejected?
        if application_choice.rejected_by_default
          rows << { key: 'Rejected by default at', value: application_choice.rejected_at.to_s(:govuk_date_and_time) }
        else
          rows << { key: 'Rejected at', value: application_choice.rejected_at.to_s(:govuk_date_and_time) }
        end
        if rejection_reasons_text
          rows << { key: 'Rejection reason', value: rejection_reasons_text }
        end
      end

      rows << { key: 'Sent to provider at', value: application_choice.sent_to_provider_at.to_s(:govuk_date_and_time) } if application_choice.sent_to_provider_at
      rows << { key: 'Reject by default at', value: application_choice.reject_by_default_at.to_s(:govuk_date_and_time) } if application_choice.reject_by_default_at && application_choice.awaiting_provider_decision?
      rows << { key: 'Decline by default at', value: application_choice.decline_by_default_at.to_s(:govuk_date_and_time) } if application_choice.decline_by_default_at && application_choice.offer?

      if visible_over_vendor_api?
        application_json = AllowedCrossNamespaceUsage::VendorAPISingleApplicationPresenter.new(application_choice).as_json
        rows << {
          key: 'Vendor API',
          value: govuk_details(summary: 'See this application choice as it appears over the Vendor API') do
            json_code_sample(application_json)
          end,
        }
      else
        rows << { key: 'Vendor API', value: 'This application hasn’t been sent to the provider yet, so it isn’t available over the Vendor API' }
      end

      if application_choice.interviews.present?
        interview_blocks = application_choice.interviews.order('created_at').map do |interview|
          render(SupportInterface::InterviewDetailsComponent.new(interview: interview))
        end

        rows << { key: 'Interviews', value: interview_blocks }
      end

      rows
    end

  private

    def rejection_reasons_text
      @_rejection_reasons_text ||= begin
        if application_choice.structured_rejection_reasons.present?
          render(
            ReasonsForRejectionComponent.new(
              application_choice: application_choice,
              reasons_for_rejection: ReasonsForRejection.new(application_choice.structured_rejection_reasons),
              editable: false,
            ),
          )
        elsif application_choice.rejection_reason.present?
          application_choice.rejection_reason
        end
      end
    end

    def visible_over_vendor_api?
      ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER.include?(application_choice.status.to_sym)
    end
  end
end
