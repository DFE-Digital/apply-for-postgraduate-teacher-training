class ApplicationChoicesRejectByDefaultDays < ActiveRecord::Migration[6.0]
  def change
    add_column :application_choices, :reject_by_default_days, :integer
  end
end
