module ProviderInterface
  class ApplicationChoicePresenter
    def initialize(application_choice)
      @application_choice = application_choice
      @application_form = application_choice.application_form
    end

    def full_name
      "#{application_choice.application_form.first_name} #{application_choice.application_form.last_name}"
    end

    def course_name_and_code
      "#{application_choice.course.name} (#{application_choice.course.code})"
    end

    def status_name
      I18n.t!("application_choice.status_name.#{application_choice.status}")
    end

    def updated_at
      application_choice.updated_at.strftime('%e %b %Y %l:%M%P')
    end

    def to_param
      application_choice.to_param
    end

    def date_of_birth
      application_form.date_of_birth
    end

  private

    attr_reader :application_choice, :application_form
  end
end
