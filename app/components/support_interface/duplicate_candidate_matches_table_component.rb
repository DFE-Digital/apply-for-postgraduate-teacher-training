module SupportInterface
  class DuplicateCandidateMatchesTableComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :matches

    def initialize(matches:)
      @matches = matches
    end

    def table_rows
      matches.map(&:symbolize_keys)
    end
  end
end
