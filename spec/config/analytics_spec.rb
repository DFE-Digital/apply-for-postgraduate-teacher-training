require 'rails_helper'

RSpec.describe 'analytics.yml' do
  it 'is valid' do
    config = Rails.configuration.analytics

    config.each do |table_name, fields|
      model = table_name.to_s.classify.constantize
      expect(fields & model.column_names).to match_array(fields)
    end
  end
end
