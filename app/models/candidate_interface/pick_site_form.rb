module CandidateInterface
  class PickSiteForm
    include ActiveModel::Model

    attr_accessor :application_form, :provider_id, :course_id, :study_mode, :course_option_id
    validates :course_option_id, presence: true
    validate :candidate_can_only_apply_to_3_courses, on: :save

    def available_sites
      relation = CourseOption.selectable.includes(:site).where(course_id: course.id)
      relation = relation.where(study_mode: study_mode)
      relation.sort_by { |course_option| course_option.site.name }
    end

    def save
      return unless valid?(:save)

      application_form.application_choices.create!(
        course_option: course_option,
      )
    end

    def update(application_choice)
      return unless valid?

      application_choice.update!(course_option: course_option)
    end

  private

    def course_option
      CourseOption.find(course_option_id)
    end

    def course
      @course ||= provider.courses.find(course_id)
    end

    def provider
      @provider ||= Provider.find(provider_id)
    end

    def candidate_can_only_apply_to_3_courses
      if application_form.apply_1?
        return if application_form.application_choices.count <= 2

        errors[:base] << 'You can only apply for up to 3 courses'
      else
        return if application_form.application_choices.count == 0

        errors[:base] << 'You can only apply to 1 course'
      end
    end
  end
end
