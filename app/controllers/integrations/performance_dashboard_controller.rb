module Integrations
  class PerformanceDashboardController < ApplicationController
    def dashboard
      raise ArgumentError unless params[:year].in?([nil, '2020', '2021'])

      @statistics = PerformanceStatistics.new(params[:year])
    end
  end
end
