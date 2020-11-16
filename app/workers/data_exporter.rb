class DataExporter
  include Sidekiq::Worker

  def perform(importer_class, data_export_id)
    RequestLocals.store[:debugging_info] = { data_export_id: data_export_id, importer_class: importer_class }

    Rails.logger.info 'Sidekiq running. Loading data export record'
    data_export = DataExport.find(data_export_id)

    Rails.logger.info 'Started CSV generation'
    csv_data = generate_csv(
      importer_class.constantize.new.data_for_export,
    )
    Rails.logger.info 'Finished CSV generation'

    Rails.logger.info 'Started writing CSV'
    data_export.update!(
      data: csv_data,
      completed_at: Time.zone.now,
    )
    Rails.logger.info 'Finished writing CSV. Sidekiq done'
  end

private

  def generate_csv(objects, header_row = nil)
    header_row ||= objects.to_a.first&.keys
    SafeCSV.generate(objects.map(&:values), header_row)
  end
end
