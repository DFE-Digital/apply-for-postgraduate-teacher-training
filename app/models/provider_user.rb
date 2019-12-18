class ProviderUser < ActiveRecord::Base
  has_and_belongs_to_many :providers

  def provider
    providers.first
  end

  def self.load_from_session(session)
    dfe_sign_in_user = DfESignInUser.load_from_session(session)
    return unless dfe_sign_in_user

    if FeatureFlag.active?('provider_permissions_in_database')
      ProviderUser.find_by(
        dfe_sign_in_uid: dfe_sign_in_user.dfe_sign_in_uid,
      )
    else
      LegacyProviderUser.new(
        email_address: dfe_sign_in_user.email_address,
        dfe_sign_in_uid: dfe_sign_in_user.dfe_sign_in_uid,
      )
    end
  end
end
