class GetApplicationChoicesForProviders
  def self.call(providers:)
    providers = Array.wrap(providers).select(&:present?)

    raise MissingProvider if providers.none?

    includes = [
      :course,
      :course_option,
      :offered_course_option,
      :application_form,
      :provider,
      :site,
      application_form: %i[candidate application_references application_work_experiences application_volunteering_experiences application_qualifications],
      course: %i[provider],
      course_option: [{ course: %i[provider] }, :site],
    ]

    ApplicationChoice.includes(*includes)
      .where('courses.provider_id' => providers, 'courses.recruitment_cycle_year' => RecruitmentCycle.visible_years)
      .or(ApplicationChoice.includes(*includes)
        .where('courses.accredited_provider_id' => providers, 'courses.recruitment_cycle_year' => RecruitmentCycle.visible_years))
      .where('status IN (?)', ApplicationStateChange.states_visible_to_provider).includes([:accredited_provider])
  end
end
