class ApplicationController < ActionController::Base
  include Passwordless::ControllerHelpers

  helper_method :current_candidate

  private

  def current_candidate
    @current_candidate ||= authenticate_by_session(Candidate)
  end

  def require_candidate!
    return if current_candidate

    redirect_to 'candidates/invalid-token'
  end
end
