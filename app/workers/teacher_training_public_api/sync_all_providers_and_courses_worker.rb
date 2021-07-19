module TeacherTrainingPublicAPI
  class SyncAllProvidersAndCoursesWorker
    include Sidekiq::Worker
    sidekiq_options retry: 3, queue: :low_priority

    def perform(incremental = true, year = ::RecruitmentCycle.current_year)
      SyncSubjects.new.perform
      SyncAllProvidersAndCourses.call(recruitment_cycle_year: year, incremental_sync: incremental)
    end
  end
end
