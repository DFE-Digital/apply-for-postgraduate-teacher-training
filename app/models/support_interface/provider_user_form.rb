module SupportInterface
  class ProviderUserForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :first_name, :last_name, :provider_user
    attr_reader :provider_permissions

    attr_reader :email_address

    validates :email_address, :first_name, :last_name, presence: true
    validates :email_address, email: true
    validate :email_is_unique
    validates :provider_permissions, presence: true

    def build
      return unless valid?

      @provider_user ||= ProviderUser.new
      @provider_user.first_name = first_name
      @provider_user.last_name = last_name
      @provider_user.email_address = email_address
      @provider_user if @provider_user.valid?
    end

    def email_address=(raw_email_address)
      @email_address = raw_email_address.downcase.strip
    end

    def available_providers
      @available_providers ||= Provider.order(name: :asc)
    end

    def persisted?
      @provider_user && @provider_user.persisted?
    end

    def self.from_provider_user(provider_user)
      new(
        provider_user: provider_user,
        first_name: provider_user.first_name,
        last_name: provider_user.last_name,
        email_address: provider_user.email_address,
      )
    end

    def forms_for_possible_permissions
      possible_permissions.map do |p|
        ProviderPermissionsForm.new(active: p.persisted?, provider_permission: p)
      end
    end

    def possible_permissions
      Provider.where(sync_courses: true).pluck(:id).map do |id|
        ProviderPermissions.find_or_initialize_by(
          provider_id: id,
          provider_user_id: provider_user.try(:id),
        )
      end
    end

    def provider_permissions=(attributes)
      forms = attributes.map { |_, attrs| ProviderPermissionsForm.new(attrs) }.select(&:active)
      @provider_permissions = forms.map do |form|
        permission = ProviderPermissions.find_or_initialize_by(
          provider_id: form.provider_permission[:provider_id],
          provider_user_id: provider_user.try(:id),
        )
        permission.manage_users = form.provider_permission.fetch(:manage_users, false)
        permission
      end
    end

    def deselected_provider_permissions
      possible_permissions - @provider_permissions
    end

  private

    def email_is_unique
      return if persisted? && provider_user.email_address == email_address

      return unless ProviderUser.exists?(email_address: email_address)

      errors.add(:email_address, 'This email address is already in use')
    end
  end
end
