class DropStructuredGradesFromQualifications < ActiveRecord::Migration[6.0]
  def change
    remove_column :application_qualifications, :structured_grades, :jsonb
  end
end
