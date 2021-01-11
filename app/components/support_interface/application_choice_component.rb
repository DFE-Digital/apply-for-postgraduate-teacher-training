module SupportInterface
  class ApplicationChoiceComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_choice

    def initialize(application_choice)
      @application_choice = application_choice
    end

    def rows
      rows = [
        { key: 'Recruitment cycle', value: application_choice.offered_option.course.recruitment_cycle_year },
        { key: 'Provider', value: govuk_link_to(application_choice.offered_course.provider.name_and_code, support_interface_provider_path(application_choice.offered_course.provider)) },
        { key: 'Accredited body', value: accredited_body.present? ? govuk_link_to(accredited_body.name_and_code, support_interface_provider_path(accredited_body)) : nil },
        { key: 'Course', value: render(SupportInterface::CourseNameAndStatusComponent.new(application_choice: application_choice)) },
        { key: 'Location', value: render(SupportInterface::LocationStatusComponent.new(application_choice: application_choice)) },
        { key: 'Study mode', value: application_choice.offered_option.study_mode.humanize },
        { key: 'Status', value: render(SupportInterface::ApplicationStatusTagComponent.new(status: application_choice.status)) },
      ]

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

      rows << { key: 'Feedback', value: application_choice.rejection_reason } if application_choice.rejection_reason.present?
      rows << { key: 'Sent to provider at', value: application_choice.sent_to_provider_at.to_s(:govuk_date_and_time) } if application_choice.sent_to_provider_at
      rows << { key: 'Reject by default at', value: application_choice.reject_by_default_at.to_s(:govuk_date_and_time) } if application_choice.reject_by_default_at
      rows << { key: 'Decline by default at', value: application_choice.decline_by_default_at.to_s(:govuk_date_and_time) } if application_choice.decline_by_default_at

      rows
    end

    def accredited_body
      application_choice.course.accredited_provider
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
  end
end
