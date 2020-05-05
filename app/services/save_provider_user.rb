class SaveProviderUser
  def initialize(provider_user:, provider_permissions: [], deselected_provider_permissions: [])
    @provider_user = provider_user
    @provider_permissions = provider_permissions
    @deselected_provider_permissions = deselected_provider_permissions
  end

  def call!
    @provider_user.save!
    update_provider_permissions!
    @provider_user.reload
  end

private

  def update_provider_permissions!
    ActiveRecord::Base.transaction do
      destroy_deselected_provider_permissions!
      add_new_provider_permissions!
      updated_existing_provider_permissions!
    end
  end

  def destroy_deselected_provider_permissions!
    @deselected_provider_permissions.each(&:destroy!)
  end

  def add_new_provider_permissions!
    new_provider_permissions = @provider_permissions - @provider_user.provider_permissions
    new_provider_permissions.each do |pp|
      pp.provider_user_id = @provider_user.id if pp.provider_user_id.blank?
      pp.save!
    end
  end

  def updated_existing_provider_permissions!
    existing_provider_permissions = @provider_permissions & @provider_user.provider_permissions
    existing_provider_permissions.each { |p| p.save! if p.changed? }
  end
end
