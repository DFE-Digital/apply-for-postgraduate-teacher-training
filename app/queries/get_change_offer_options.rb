class GetChangeOfferOptions
  attr_accessor :application_choice, :user

  def initialize(application_choice:, user:)
    @application_choice = application_choice
    @user = user
  end

  def available_providers
    courses = Course.where(open_on_apply: true,
                          provider: user.providers,
                          recruitment_cycle_year: application_choice.offered_course.recruitment_cycle_year,)
  end

  #   @available_courses = Course.where(
  #     open_on_apply: true,
  #     provider: application_choice.offered_course.provider,
  #     study_mode: study_mode_for_other_courses,
  #     recruitment_cycle_year: application_choice.offered_course.recruitment_cycle_year,
  #   ).order(:name)
  #
  #   @available_study_modes = CourseOption.where(
  #     course: application_choice.offered_course,
  #   ).pluck(:study_mode).uniq
  #
  #   @available_course_options = CourseOption.where(
  #     course: application_choice.offered_course,
  #     study_mode: application_choice.offered_option.study_mode, # preserving study_mode
  #   ).includes(:site).order('sites.name')
  # end

private

end
