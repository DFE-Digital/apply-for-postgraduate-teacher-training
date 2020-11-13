class ApplicationFeedback < ApplicationRecord
  self.table_name = 'application_feedback'
  belongs_to :application_form, touch: true
  serialize :section
end
