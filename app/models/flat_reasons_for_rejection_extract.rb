class FlatReasonsForRejectionExtract
  include ActiveModel::Model

  def initialize(structured_rejection_reasons)
    @structured_rejection_reasons = structured_rejection_reasons
  end

  def candidate_behaviour?
    top_level_reasons('candidate_behaviour_y_n')
  end

  def didnt_reply_to_interview_offer?
    sub_level_reasons('candidate_behaviour_what_did_the_candidate_do', 'didnt_reply_to_interview_offer')
  end

  def didnt_attend_interview?
    sub_level_reasons('candidate_behaviour_what_did_the_candidate_do', 'didnt_attend_interview')
  end

  def candidate_behaviour_other_details
    other_detail_or_what_to_improve('candidate_behaviour_other')
  end

  def quality_of_application?
    top_level_reasons('quality_of_application_y_n')
  end

  def personal_statement?
    sub_level_reasons('quality_of_application_which_parts_needed_improvement', 'personal_statement')
  end

  def quality_of_application_personal_statement_what_to_improve
    other_detail_or_what_to_improve('quality_of_application_personal_statement_what_to_improve')
  end

  def subject_knowledge?
    sub_level_reasons('quality_of_application_which_parts_needed_improvement', 'subject_knowledge')
  end

  def quality_of_application_subject_knowledge_what_to_improve
    other_detail_or_what_to_improve('quality_of_application_subject_knowledge_what_to_improve')
  end

  def quality_of_application_other_details
    other_detail_or_what_to_improve('quality_of_application_other_details')
  end

  def qualifications?
    top_level_reasons('qualifications_y_n')
  end

  def no_maths_gcse?
    sub_level_reasons('qualifications_which_qualifications', 'no_maths_gcse')
  end

  def no_science_gcse?
    sub_level_reasons('qualifications_which_qualifications', 'no_science_gcse')
  end

  def no_english_gcse?
    sub_level_reasons('qualifications_which_qualifications', 'no_english_gcse')
  end

  def no_degree?
    sub_level_reasons('qualifications_which_qualifications', 'no_degree')
  end

  def qualifications_other_details
    other_detail_or_what_to_improve('qualifications_other_details')
  end



  # These three methods are copied from the application_choices_export.rb .... currently doesn't provide enough granularity
  def format_structured_rejection_reasons
    return nil if @structured_rejection_reasons.blank?

    select_high_level_rejection_reasons(@structured_rejection_reasons)
    .keys
    .map { |reason| format_reason(reason) }
    .join("\n")
  end

  def select_high_level_rejection_reasons(structured_rejection_reasons)
    structured_rejection_reasons.select { |reason, value| value == 'Yes' && reason.include?('_y_n') }
  end

  def format_reason(reason)
    reason
    .delete_suffix('_y_n')
    .humanize
  end

  private

  def top_level_reasons(key)
    return nil if @structured_rejection_reasons["#{key}"].blank?

    @structured_rejection_reasons.select { |reason, value| value == 'Yes' && reason == "#{key}" }.present?
  end

  def sub_level_reasons(key, value)
    return nil if @structured_rejection_reasons["#{key}"].blank?

    @structured_rejection_reasons["#{key}"].include?("#{value}")
  end

  def other_detail_or_what_to_improve(key)
    return nil if @structured_rejection_reasons["#{key}"].blank?

    @structured_rejection_reasons["#{key}"]
  end
end
