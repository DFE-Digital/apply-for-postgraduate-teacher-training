module SupportInterface
  class ReasonsForRejectionSearchResultsComponent < ViewComponent::Base
    include ViewHelper

    def initialize(search_attribute:, search_value:, application_choices:)
      @search_attribute = search_attribute
      @search_value = search_value
      @application_choices = application_choices
    end

    def summary_list_rows_for(application_choice)
      application_choice.structured_rejection_reasons.map { |reason, value|
        next unless top_level_reason?(reason, value)

        {
          key: reason_text_for(reason),
          value: sub_reason_text_for(application_choice, reason),
        }
      }.compact
    end

    def search_value_text
      if @search_value == 'Yes'
        i18n_key = SupportInterface::SubReasonsForRejectionTableComponent::TOP_LEVEL_REASONS_TO_I18N_KEYS[@search_attribute].to_s
        t("reasons_for_rejection.#{i18n_key}.title")
      else
        [
          t("reasons_for_rejection.#{@search_attribute}.title"),
          t("reasons_for_rejection.#{@search_attribute}.#{@search_value}"),
        ].join(' - ')
      end
    end

    def sub_reason_text_for(application_choice, top_level_reason)
      sub_reason = sub_reason_for(top_level_reason)
      return '' if sub_reason.blank?

      application_choice.structured_rejection_reasons[sub_reason]
        &.map { |value| sub_reason_value_text(application_choice, top_level_reason, sub_reason, value) }
        &.join('<br/>')
        &.html_safe
    end

    def sub_reason_value_text(application_choice, top_level_reason, sub_reason, value)
      i18n_key = SupportInterface::SubReasonsForRejectionTableComponent::TOP_LEVEL_REASONS_TO_I18N_KEYS[top_level_reason].to_s
      text = t("reasons_for_rejection.#{i18n_key}.#{value}")

      detail_questions = ProviderInterface::ReasonsForRejectionWizard::INITIAL_QUESTIONS.dig(
        top_level_reason.to_sym, sub_reason.to_sym, value.to_sym
      )
      additional_text =
        if detail_questions.is_a?(Array)
          detail_questions.map { |detail_question| application_choice.structured_rejection_reasons[detail_question.to_s] }.compact.join('<br/>')
        else
          application_choice.structured_rejection_reasons[detail_questions.to_s]
        end

      [text, additional_text].reject(&:blank?).join(' - ')
    end

    def reason_text_for(top_level_reason)
      i18n_key = SupportInterface::SubReasonsForRejectionTableComponent::TOP_LEVEL_REASONS_TO_I18N_KEYS[top_level_reason].to_s
      t("reasons_for_rejection.#{i18n_key}.title")
    end

    def top_level_reason?(reason, value)
      reason =~ /_y_n$/ && value == 'Yes'
    end

  private

    def sub_reason_for(top_level_reason)
      ReasonsForRejectionCountQuery::TOP_LEVEL_REASONS_TO_SUB_REASONS[top_level_reason.to_sym].to_s
    end
  end
end
