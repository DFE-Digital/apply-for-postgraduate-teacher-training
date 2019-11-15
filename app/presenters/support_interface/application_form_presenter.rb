module SupportInterface
  class ApplicationFormPresenter
    def initialize(application_form)
      @application_form = application_form
    end

    def full_name
      "#{application_form.first_name} #{application_form.last_name}"
    end

    def updated_at
      application_form.updated_at
    end

    def date_of_birth
      application_form.date_of_birth
    end

    def name_and_support_reference
      if application_form.support_reference
        "#{full_name} (#{application_form.support_reference})"
      else
        full_name
      end
    end

    def to_param
      application_form.id.to_s
    end

  private

    attr_reader :application_form
  end
end
