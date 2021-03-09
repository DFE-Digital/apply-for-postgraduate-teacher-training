module TeacherTrainingPublicAPI
  class SyncAllProvidersAndCourses
    def self.call
      is_last_page = false
      page_number = 0
      until is_last_page
        page_number += 1
        response = TeacherTrainingPublicAPI::Provider
          .where(year: ::RecruitmentCycle.current_year)
          .paginate(page: page_number, per_page: 500)
          .all
        sync_providers(response)
        is_last_page = true if response.links.links['next'].nil?
      end

      TeacherTrainingPublicAPI::SyncCheck.set_last_sync(Time.zone.now)
    rescue JsonApiClient::Errors::ApiError
      raise TeacherTrainingPublicAPI::SyncError
    end

    def self.sync_providers(providers_from_api)
      providers_from_api.each do |provider_from_api|
        TeacherTrainingPublicAPI::SyncProvider.new(
          provider_from_api: provider_from_api,
          recruitment_cycle_year: ::RecruitmentCycle.current_year,
        ).call
      end
    end

    private_class_method :sync_providers
  end
end
