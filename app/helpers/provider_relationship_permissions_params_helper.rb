module ProviderRelationshipPermissionsParamsHelper
  def translate_params_for_model(permissions_params)
    ProviderRelationshipPermissions::PERMISSIONS.inject({}) do |hash, permission|
      hash["training_provider_can_#{permission}"] = permissions_params[permission.to_s].include? 'training'
      hash["ratifying_provider_can_#{permission}"] = permissions_params[permission.to_s].include? 'ratifying'
      hash
    end
  end
end
