module SupportInterface
  class ProviderUserForm
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :first_name, :last_name, :permissions, :provider_user
    attr_writer :provider_ids

    attr_reader :email_address

    validates :email_address, :first_name, :last_name, presence: true
    validates :email_address, email: true
    validates :provider_ids, presence: true
    validate :email_is_unique

    def build
      return unless valid?

      @provider_user ||= ProviderUser.new
      @provider_user.first_name = first_name
      @provider_user.last_name = last_name
      @provider_user.email_address = email_address
      @provider_user.provider_ids = provider_ids
      @provider_user if @provider_user.valid?
    end

    def save
      @provider_user.save! if build
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
        provider_ids: provider_user.provider_ids,
        permissions: permissions(provider_user),
      )
    end

    def provider_ids
      return [] unless @provider_ids

      @provider_ids.reject(&:blank?)
    end

    def self.permissions(provider_user)
      {
        manage_users: ProviderPermissions.manage_users.where(provider_user: provider_user).pluck(:provider_id),
      }
    end

  private

    def email_is_unique
      return if persisted? && provider_user.email_address == email_address

      return unless ProviderUser.exists?(email_address: email_address)

      errors.add(:email_address, 'This email address is already in use')
    end
  end
end
