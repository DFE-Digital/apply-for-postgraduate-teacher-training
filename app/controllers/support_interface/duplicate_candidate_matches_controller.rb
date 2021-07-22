module SupportInterface
  class DuplicateCandidateMatchesController < SupportInterfaceController
    def index
      @matches = GetDuplicateCandidateMatches.call
    end
  end
end
