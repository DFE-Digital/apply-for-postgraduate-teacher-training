module ProviderInterface
  class ApplicationChoicePresenter
    delegate :application_qualifications, :references, to: :application_form
    attr_reader :application_form

    def initialize(application_choice)
      @application_choice = application_choice
      @application_form = application_choice.application_form
    end

    def id
      application_choice.id
    end

    def status
      application_choice.status
    end

    def status_tag_text
      application_choice.status.humanize.titleize
    end

    def status_tag_class
      case application_choice.status
      when 'offer'
        'app-tag--offer'
      when 'rejected'
        'app-tag--rejected'
      else
        'app-tag--new'
      end
    end

    def full_name
      "#{application_choice.application_form.first_name} #{application_choice.application_form.last_name}"
    end

    def course_name_and_code
      application_choice.course.name_and_code
    end

    def course_start_date
      application_choice.course.start_date
    end

    def course_preferred_location
      application_choice.course.course_options.first.site.name
    end

    def status_name
      I18n.t!("provider_application_states.#{application_choice.status}")
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

    def phone_number
      application_form.phone_number
    end

    def email_address
      application_form.candidate.email_address
    end

    def degrees
      application_qualifications.degrees
    end

    def gcses_or_equivalent
      application_qualifications.gcses
    end

    def other_qualifications
      application_qualifications.other
    end

    def first_reference
      references.first
    end

    def second_reference
      references.second
    end

  private

    attr_reader :application_choice
  end
end
