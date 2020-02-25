require 'csv'

module SupportInterface
  class PerformanceController < SupportInterfaceController
    def index; end

    def application_timings
      applications = SupportInterface::ApplicationsExport.new.applications

      csv = CSV.generate do |rows|
        rows << applications.first.keys

        applications.each do |a|
          rows << a.values
        end
      end

      render plain: csv
    end

    def referee_survey
      responses = SupportInterface::RefereeSurveyExport.new.call

      csv = CSV.generate do |rows|
        rows << responses&.first&.keys

        responses&.each do |response|
          rows << response.values
        end
      end

      send_data csv, filename: "referee-survey-#{Time.zone.today}.csv", disposition: :attachment
    end
  end
end
