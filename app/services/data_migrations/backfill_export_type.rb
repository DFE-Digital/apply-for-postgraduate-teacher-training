module DataMigrations
  class BackfillExportType
    TIMESTAMP = 20210326113829
    MANUAL_RUN = true

    def change
      data_exports = DataExport.all.where(export_type: nil)

      data_exports.each { |export| export.update!(export_type: export_type(export)) }
    end

  private

    def export_type(export)
      case export.name
      when 'Unexplained breaks in work history'
        'work_history_break'
      when 'Locations', 'Locations export'
        'persona_export'
      when 'Applications for TAD'
        'tad_applications'
      when 'Provider performance for TAD'
        'tad_provider_performance'
      when 'Candidate survey', 'Daily export of applications for TAD', 'Daily export of notifications breakdown', 'RejectedCandidatesExport'
        nil
      else
        DataExport::EXPORT_TYPES.select { |_key, value| value[:name] == export.name }.values[0][:export_type]
      end
    end
  end
end
