# TODO: The validations have been lifted from `WorkExperienceForm`
# and needs to be refactored out to remove the duplication.

module CandidateInterface
  class VolunteeringRoleForm
    include ActiveModel::Model

    attr_accessor :id, :role, :organisation, :details, :working_with_children,
                  :start_date_day, :start_date_month, :start_date_year,
                  :end_date_day, :end_date_month, :end_date_year

    validates :role, :organisation, :details, :working_with_children, presence: true

    validates :role, :organisation, length: { maximum: 60 }

    validates :details, word_count: { maximum: 150 }

    validate :start_date_valid
    validate :end_date_valid, unless: :end_date_blank?
    validate :end_date_before_current_year_and_month, if: :end_date_valid?
    validate :start_date_before_end_date, if: :start_date_and_end_date_valid?

    class << self
      def build_all_from_application(application_form)
        application_form.application_volunteering_experiences.order(created_at: :desc).map do |volunteering_role|
          new_volunteering_role_form(volunteering_role)
        end
      end

      def build_from_application(application_form, volunteering_role_id)
        volunteering_role = application_form.application_volunteering_experiences.find(volunteering_role_id)

        new_volunteering_role_form(volunteering_role)
      end

    private

      def new_volunteering_role_form(volunteering_role)
        new(
          id: volunteering_role.id,
          role: volunteering_role.role,
          organisation: volunteering_role.organisation,
          details: volunteering_role.details,
          working_with_children: volunteering_role.working_with_children.to_s,
          start_date_month: volunteering_role.start_date.month,
          start_date_year: volunteering_role.start_date.year,
          end_date_month: volunteering_role.end_date&.month || '',
          end_date_year: volunteering_role.end_date&.year || '',
        )
      end
    end

    def save(application_form)
      return false unless valid?

      application_form.application_volunteering_experiences.create!(map_attributes)
      application_form.update!(volunteering_experience: true)

      true
    end

    def update(application_form)
      return false unless valid?

      volunteering_role = application_form.application_volunteering_experiences.find(id)

      volunteering_role.update!(map_attributes)
    end

    def start_date
      valid_or_invalid_start_date(start_date_year, start_date_month)
    end

    def end_date
      valid_end_date_or_nil(end_date_year, end_date_month)
    end

  private

    def valid_end_date_or_nil(year, month)
      date_args = [year, month, 1].map(&:to_i)
      if year.present? && Date.valid_date?(*date_args)
        Date.new(*date_args)
      elsif year.present? || month.present?
        Struct.new(:day, :month, :year).new(1, month, year)
      end
    end

    def valid_or_invalid_start_date(year, month)
      date_args = [year, month, 1].map(&:to_i)
      if year.present? && Date.valid_date?(*date_args)
        Date.new(*date_args)
      else
        Struct.new(:day, :month, :year).new(1, month, year)
      end
    end

    def end_date_blank?
      end_date_year.blank? && end_date_month.blank?
    end

    def end_date_valid
      errors.add(:end_date, :invalid) unless end_date.is_a?(Date)
    end

    def start_date_valid
      errors.add(:start_date, :invalid) unless start_date.is_a?(Date)
    end

    def start_date_before_end_date
      if start_date_and_end_date_valid?
        errors.add(:start_date, :before) unless start_date <= end_date
      end
    end

    def end_date_before_current_year_and_month
      if end_date.year > Date.today.year || \
          end_date.year == Date.today.year && end_date.month > Date.today.month
        errors.add(:end_date, :in_the_future)
      end
    end

    def start_date_and_end_date_valid?
      end_date.is_a?(Date) && start_date.is_a?(Date)
    end

    def end_date_valid?
      end_date.is_a?(Date)
    end

    def map_attributes
      {
        role: role,
        organisation: organisation,
        details: details,
        working_with_children: ActiveModel::Type::Boolean.new.cast(working_with_children),
        start_date: start_date,
        end_date: end_date,
      }
    end
  end
end
