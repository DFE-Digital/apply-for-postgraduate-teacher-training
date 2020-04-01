module CourseOptionHelpers
  def course_option_for_provider(provider:, course: nil, site: nil, study_mode: 'full_time')
    course ||= create(:course, :open_on_apply, provider: provider)
    site ||= create(:site, provider: provider)
    create(:course_option, course: course, site: site, study_mode: study_mode)
  end

  def course_option_for_provider_code(provider_code:)
    provider = create(:provider, :with_signed_agreement, code: provider_code)
    course = create(:course, :open_on_apply, provider: provider)
    site = create(:site, provider: provider)
    create(:course_option, course: course, site: site)
  end

  def course_option_for_accredited_provider(provider:, accredited_provider:)
    course = create(:course, :open_on_apply, provider: provider, accredited_provider: accredited_provider)
    site = create(:site, provider: provider)
    create(:course_option, course: course, site: site)
  end
end
