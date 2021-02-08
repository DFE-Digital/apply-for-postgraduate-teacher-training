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
          value: reason_detail_text_for(application_choice, reason),
        }
      }.compact
    end

    def search_title_text
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

    def reason_detail_text_for(application_choice, top_level_reason)
      sub_reason = sub_reason_for(top_level_reason)
      if sub_reason.present?
        application_choice.structured_rejection_reasons[sub_reason]
          &.map { |value| sub_reason_detail_text(application_choice, top_level_reason, sub_reason, value) }
          &.join('<br/>')
          &.html_safe
      else
        detail_reason = detail_reason_for(application_choice, top_level_reason)
      end
    end

    def sub_reason_detail_text(application_choice, top_level_reason, sub_reason, value)
      i18n_key = SupportInterface::SubReasonsForRejectionTableComponent::TOP_LEVEL_REASONS_TO_I18N_KEYS[top_level_reason].to_s
      text = mark_search_term(
        I18n.t("reasons_for_rejection.#{i18n_key}.#{value}"), 
        value.to_s == @search_value.to_s,
      )

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
      mark_search_term(t("reasons_for_rejection.#{i18n_key}.title"), top_level_reason.to_s == @search_attribute.to_s)
    end

    def top_level_reason?(reason, value)
      reason =~ /_y_n$/ && value == 'Yes'
    end

  private

    def mark_search_term(text, mark)
      mark ? "<mark>#{text}</mark>".html_safe : text
    end

    def sub_reason_for(top_level_reason)
      ReasonsForRejectionCountQuery::TOP_LEVEL_REASONS_TO_SUB_REASONS[top_level_reason.to_sym].to_s
    end

    def detail_reason_for(application_choice, top_level_reason)
      detail_questions = ProviderInterface::ReasonsForRejectionWizard::INITIAL_QUESTIONS[top_level_reason.to_sym].keys
      detail_questions.map { |detail_question| application_choice.structured_rejection_reasons[detail_question.to_s] }.compact.join('<br/>')
    end
  end
end
