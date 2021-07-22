class PerformanceStatistics
  UNSUBMITTED_STATUSES = %i[unsubmitted_not_started_form unsubmitted_in_progress].freeze
  PROCESSING_STATUSES = %i[awaiting_provider_decisions awaiting_candidate_response].freeze
  ACCEPTED_STATUSES = %i[pending_conditions recruited offer_deferred].freeze

  attr_reader :year

  def initialize(year)
    @year = year
  end

  def candidate_count
    candidates = Candidate.all

    if year.present?
      year_query = date_range_query_for_recruitment_cycle_year(year.to_i)
      candidates = candidates.where(year_query)
    end

    candidates.where(hide_in_reporting: false).uniq.count
  end

  def application_form_query
    year_clause = year ? "AND f.recruitment_cycle_year = #{year}" : ''

    <<-SQL
      WITH raw_data AS (
          SELECT
              c.id,
              f.id,
              f.phase,
              CASE
                WHEN #{form_is_unsubmitted_sql} AND DATE_TRUNC('second', f.updated_at) = DATE_TRUNC('second', f.created_at) THEN ARRAY['0', 'unsubmitted_not_started_form']
                WHEN #{form_is_unsubmitted_sql} AND DATE_TRUNC('second', f.updated_at) <> DATE_TRUNC('second', f.created_at) THEN ARRAY['1', 'unsubmitted_in_progress']
                WHEN 'awaiting_provider_decision' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['4', 'awaiting_provider_decisions']
                WHEN 'offer' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['6', 'awaiting_candidate_response']
                WHEN 'recruited' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['8', 'recruited']
                WHEN 'pending_conditions' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['7', 'pending_conditions']
                WHEN 'offer_deferred' = ANY(ARRAY_AGG(ch.status)) THEN ARRAY['10', 'offer_deferred']
                WHEN #{form_ended_without_success_sql} THEN ARRAY['5', 'ended_without_success']
                ELSE ARRAY['10', 'unknown_state']
              END status
          FROM
              application_forms f
          LEFT JOIN
              candidates c ON f.candidate_id = c.id
          LEFT JOIN
              application_choices ch ON ch.application_form_id = f.id
          WHERE
              NOT c.hide_in_reporting
              #{year_clause}
          GROUP BY
              c.id, f.id, f.phase
      )
      SELECT
          raw_data.status[2],
          raw_data.phase,
          COUNT(*)
      FROM
          raw_data
      GROUP BY
          raw_data.status, raw_data.phase
      ORDER BY
          raw_data.status[1]
    SQL
  end

  def form_is_unsubmitted_sql
    "('unsubmitted' = ANY(ARRAY_AGG(ch.status)) OR '{NULL}' = ARRAY_AGG(DISTINCT ch.status))"
  end

  def form_ended_without_success_sql
    sql = 'ARRAY_AGG(DISTINCT ch.status)'
    ApplicationStateChange::UNSUCCESSFUL_END_STATES.each do |state|
      sql = "ARRAY_REMOVE(#{sql}, '#{state}')"
    end

    "#{sql} = '{}'"
  end

  def [](key)
    application_form_status_counts
      .select { |x| x['status'] == key.to_s }
      .map { |row| row['count'] }
      .sum
  end

  def total_form_count(only: nil, except: [], phase: nil)
    application_form_status_counts
      .select { |row| only.nil? || row['status'].to_sym.in?(only) }
      .select { |row| phase.nil? || row['phase']&.to_sym == phase.to_sym }
      .reject { |row| row['status'].to_sym.in?(except) }
      .map { |row| row['count'] }
      .sum
  end

  def application_form_status_counts
    @application_form_status_counts ||= ActiveRecord::Base
      .connection
      .execute(application_form_query)
      .to_a
  end

  def total_submitted_count
    total_form_count(except: UNSUBMITTED_STATUSES)
  end

  def apply_again_submitted_count
    total_form_count(except: UNSUBMITTED_STATUSES, phase: :apply_2)
  end

  def unsubmitted_application_form_status_total_counts
    application_form_status_total_counts(only: UNSUBMITTED_STATUSES)
  end

  def still_being_processed_count
    total_form_count(only: PROCESSING_STATUSES)
  end

  def still_being_processed_application_form_status_total_counts
    application_form_status_total_counts(only: PROCESSING_STATUSES)
  end

  def ended_without_success_count
    total_form_count(only: %i[ended_without_success])
  end

  def ended_without_success_application_form_status_total_counts
    application_form_status_total_counts(only: %i[ended_without_success])
  end

  def ended_without_success_application_withdrawn_at_candidate_request_count
    @withdrawn_at_candidates_request_count ||= GetApplicationChoicesWithdrawnAtCandidatesRequest.call.count
  end

  def ended_without_success_application_withdrawn_by_candidate_count
    application_form_status_total_counts(only: %i[withdrawn_at_candidates_request])
  end

  def accepted_offer_count
    total_form_count(only: ACCEPTED_STATUSES)
  end

  def accepted_offer_application_form_status_total_counts
    application_form_status_total_counts(only: ACCEPTED_STATUSES)
  end

  def apply_again_accepted_offer_count
    total_form_count(only: %i[pending_conditions recruited offer_deferred], phase: :apply_2)
  end

  def rejected_by_default_count
    @rejected_by_default_count ||= begin
      scope = ApplicationForm
        .joins(:application_choices)
        .where('application_choices.status': 'rejected', 'application_choices.rejected_by_default': true)
        .distinct
      scope = scope.where('application_forms.recruitment_cycle_year': year) if year.present?
      scope.count
    end
  end

  def percentage_of_providers_onboarded
    @percentage_of_providers_onboarded ||=
      begin
        total_count = Provider.count
        if total_count.positive?
          onboarded_count = Provider.joins(:courses).where('courses.open_on_apply': true).distinct.count
          "#{((onboarded_count * 100).to_f / total_count).round}%"
        else
          '-'
        end
      end
  end

  def total_application_choice_count
    application_choices.count
  end

  def application_choices_by_provider_type
    defaults = { 'university' => 0, 'scitt' => 0, 'lead_school' => 0, 'ratified_by_scitt' => 0, 'ratified_by_university' => 0 }

    by_ratifier_type = application_choices
      .joins(course_option: { course: :accredited_provider })
      .group(:provider_type)
      .count.to_h

    by_ratifier_type.transform_keys! { |k| "ratified_by_#{k}" }

    by_training_provider_type = application_choices
        .joins(course_option: { course: :provider })
        .group(:provider_type)
        .count.to_h

    [defaults, by_ratifier_type, by_training_provider_type].reduce(:merge)
  end

  def withdrawn_at_candidates_request_count
    audits_joins_sql = <<-SQL.squish
      INNER JOIN audits ON audits.auditable_type = 'ApplicationChoice'
      AND audits.auditable_id = application_choices.id
      AND audits.user_type = 'ProviderUser'
      AND audits.comment IN ('Declined on behalf of the candidate', 'Withdrawn on behalf of the candidate')
    SQL

    @withdrawn_at_candidates_request_count ||= begin
      scope = ApplicationForm
        .joins(:application_choices)
        .joins(audits_joins_sql)
        .where('application_choices.status': %w[declined withdrawn])
        .distinct

      scope = scope.where('application_forms.recruitment_cycle_year': year) if year.present?
      scope.count
    end
  end

  def withdrawn_by_candidate_count
    scope = ApplicationForm
      .joins(:application_choices)
      .where('application_choices.status': %w[declined withdrawn])
      .distinct

    scope = scope.where('application_forms.recruitment_cycle_year': year) if year.present?
    scope.count - withdrawn_at_candidates_request_count
  end

private

  def application_choices
    choices = ApplicationChoice
      .joins(:application_form)
      .where(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)

    if year
      choices.where(application_forms: { recruitment_cycle_year: year })
    else
      choices
    end
  end

  def date_range_query_for_recruitment_cycle_year(cycle_year)
    start_date = CycleTimetable.apply_opens(cycle_year)

    query = "created_at >= '#{start_date}'"

    if CycleTimetable::CYCLE_DATES[cycle_year + 1].present?
      end_date = CycleTimetable.apply_opens(cycle_year + 1)

      query += " AND created_at <= '#{end_date}'"
    end

    query
  end

  def application_form_status_total_counts(only: nil)
    application_form_status_counts
      .select { |row| only.nil? || row['status'].to_sym.in?(only) }
      .group_by { |row| row['status'] }.map do |status, rows|
        { 'status' => status, 'count' => rows.map { |r| r['count'] }.sum }
      end
  end
end
