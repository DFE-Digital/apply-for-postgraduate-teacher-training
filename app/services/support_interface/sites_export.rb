module SupportInterface
  class SitesExport
    include GeocodeHelper

    def sites
      relevant_sites.map do |site|
        {
          'id' => site.id,
          'code' => site.code,
          'provider code' => site.provider.code,
          'distance from provider' => format_distance(site, site.provider, with_units: false),
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
