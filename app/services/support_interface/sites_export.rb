module SupportInterface
  class SitesExport
    include GeocodeHelper

    def sites
      relevant_sites.map do |site|
        {
          site_id: site.id,
          site_code: site.code,
          provider_code: site.provider.code,
          distance_from_provider: format_distance(site, site.provider, with_units: false),
        }
      end
    end

    alias_method :data_for_export, :sites

  private

    def relevant_sites
      Site.joins(:course_options, :provider)
          .where(course_options: { site_still_valid: true })
          .where(providers: { sync_courses: true })
          .order('providers.code ASC')
    end
  end
end
