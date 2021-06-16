module CandidateAPI
  class CandidatesController < ActionController::API
    include ServiceAPIUserAuthentication

    rescue_from ActionController::ParameterMissing, with: :parameter_missing
    rescue_from ParameterInvalid, with: :parameter_invalid

    # Makes PG::QueryCanceled statement timeout errors appear in Skylight
    # against the controller action that triggered them
    # instead of bundling them with every other ErrorsController#internal_server_error
    rescue_from ActiveRecord::QueryCanceled, with: :statement_timeout

    def index
      render json: { data: serialized_candidates }
    end

    def parameter_missing(e)
      error_message = e.message.split("\n").first
      render json: { errors: [{ error: 'ParameterMissing', message: error_message }] }, status: :unprocessable_entity
    end

    def parameter_invalid(e)
      render json: { errors: [{ error: 'ParameterInvalid', message: e }] }, status: :unprocessable_entity
    end

    def statement_timeout(e)
      render json: { errors: [{ error: 'QueryCanceled', message: e }] }, status: :internal_server_error
    end

  private

    def serialized_candidates
      candidates = Candidate.where('candidate_api_updated_at > ?', updated_since_params)

      candidates.map do |candidate|
        {
          id: "C#{candidate.id}",
          type: 'candidate',
          attributes: {
            email_address: candidate.email_address,
            created_at: candidate.created_at,
            updated_at: candidate.candidate_api_updated_at,
          },
        }
      end
    end

    def updated_since_params
      params.require(:updated_since)
    end
  end
end
