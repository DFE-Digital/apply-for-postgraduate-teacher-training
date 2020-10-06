module SupportInterface
  class ApplicationsFilter
    attr_reader :applied_filters

    def initialize(params:)
      @applied_filters = params
    end

    def filter_records(application_forms)
      application_forms = application_forms
        .joins(:candidate)
        .includes(:candidate, :application_choices)
        .order(updated_at: :desc)
        .page(applied_filters[:page] || 1).per(15)

      if applied_filters[:q]
        application_forms = application_forms.where("CONCAT(application_forms.first_name, ' ', application_forms.last_name, ' ', candidates.email_address, ' ', application_forms.support_reference) ILIKE ?", "%#{applied_filters[:q]}%")
      end

      if applied_filters[:phase]
        application_forms = application_forms.where('phase IN (?)', applied_filters[:phase])
      end

      application_forms
    end

    def filters
      @filters ||= [search_filter] + [phase_filter]
    end

private

    def search_filter
      {
        type: :search,
        heading: 'Name, email or reference',
        value: applied_filters[:q],
        name: 'q',
      }
    end

    def phase_filter
      {
        type: :checkboxes,
        heading: 'Phase',
        name: 'phase',
        options: [
          {
            value: 'apply_1',
            label: 'Apply 1',
            checked: applied_filters[:phase]&.include?('apply_1'),
          },
          {
            value: 'apply_2',
            label: 'Apply 2',
            checked: applied_filters[:phase]&.include?('apply_2'),
          },
        ],
      }
    end
  end
end
