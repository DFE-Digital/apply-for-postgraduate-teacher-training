module SupportInterface
  class ProvidersExport
    include GeocodeHelper

    def providers
      relevant_providers.map do |provider|
        {
          provider_name: provider.name,
          provider_code: provider.code,
          agreement_accepted_at: provider.provider_agreements.where.not(accepted_at: nil).first&.accepted_at,
          average_distance_to_site: average_distance_to_site(provider),
        }
      end
    end

    alias_method :data_for_export, :providers

  private

    def relevant_providers
      Provider
        .includes(
          :provider_agreements,
          :sites,
        )
        .where(sync_courses: true)
        .order(:name)
    end

    def average_distance_to_site(provider)
      format_average_distance(
        provider,
        provider.sites,
        with_units: false,
      )
    end
  end
end
