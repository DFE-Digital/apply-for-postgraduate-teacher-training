module ProviderInterface
  class ProviderInterfaceController < ActionController::Base
    include LogQueryParams

    before_action :authenticate_provider_user!
    before_action :add_identity_to_log
    before_action :check_data_sharing_agreements

    layout 'application'

    rescue_from MissingProvider, with: lambda { |e|
      Raven.capture_exception(e)

      render template: 'provider_interface/account_creation_in_progress', status: :forbidden
    }

    rescue_from MissingPermission, with: lambda { |e|
      Raven.capture_exception(e)

      @error = e
      render template: 'provider_interface/provider_user_permissions/missing_permission', status: :forbidden
    }

    helper_method :current_provider_user, :dfe_sign_in_user

    def current_provider_user
      !@current_provider_user.nil? ? @current_provider_user : @current_provider_user = (ProviderUser.load_from_session(session) || false)
    end

    alias_method :audit_user, :current_provider_user

  protected

    def dfe_sign_in_user
      DfESignInUser.load_from_session(session)
    end

    def authenticate_provider_user!
      return if current_provider_user

      session['post_dfe_sign_in_path'] = request.fullpath
      redirect_to provider_interface_sign_in_path
    end

    def add_identity_to_log
      return unless current_provider_user

      RequestLocals.store[:identity] = { dfe_sign_in_uid: current_provider_user.dfe_sign_in_uid }
      Raven.user_context(dfe_sign_in_uid: current_provider_user.dfe_sign_in_uid)
    end

    def check_data_sharing_agreements
      if GetPendingDataSharingAgreementsForProviderUser.call(provider_user: current_provider_user).any?
        redirect_to provider_interface_new_data_sharing_agreement_path
      end
    end

    def render_404
      render 'errors/not_found', status: :not_found
    end

    def render_403
      render 'errors/forbidden', status: :forbidden
    end
  end
end
