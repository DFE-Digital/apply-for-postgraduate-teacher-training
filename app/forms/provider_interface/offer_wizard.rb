module ProviderInterface
  class OfferWizard
    include ActiveModel::Model

    STEPS = { make_offer: %i[select_option conditions check],
              change_offer: %i[select_option providers courses study_modes locations conditions check] }.freeze

    attr_accessor :provider_id, :course_id, :course_option_id, :study_mode, :location_id,
                  :standard_conditions, :further_condition_1, :further_condition_2,
                  :further_condition_3, :further_condition_4, :current_step, :decision,
                  :action, :path_history, :wizard_path_history,
                  :provider_user_id, :application_choice_id

    validates :decision, presence: true, on: %i[select_option]
    validates :course_option_id, presence: true, on: %i[locations save]
    validates :study_mode, presence: true, on: %i[study_modes save]
    validates :course_id, presence: true, on: %i[courses save]
    validates :further_condition_1, :further_condition_2, :further_condition_3, :further_condition_4, length: { maximum: 255 }
    validate :course_option_details, if: :course_option_id, on: :save

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(last_saved_state.deep_merge(attrs))
      update_path_history(attrs)
    end

    def conditions
      @conditions = (standard_conditions + [further_condition_1, further_condition_2,
                                            further_condition_3, further_condition_4]).reject!(&:blank?)
    end

    def course_option
      @course_option = CourseOption.find(course_option_id)
    end

    def save_state!
      @state_store.write(state)
    end

    def clear_state!
      @state_store.delete
    end

    def valid_for_current_step?
      valid?(current_step.to_sym)
    end

    def next_step(step = current_step)
      index = STEPS[decision.to_sym].index(step.to_sym)
      return unless index

      next_step = STEPS[decision.to_sym][index + 1]

      return save_and_go_to_next_step(next_step) if next_step.eql?(:providers) && available_providers.one?
      return save_and_go_to_next_step(next_step) if next_step.eql?(:courses) && available_courses.one?
      return save_and_go_to_next_step(next_step) if next_step.eql?(:study_modes) && available_study_modes.one?
      return save_and_go_to_next_step(next_step) if next_step.eql?(:locations) && available_course_options.one?

      next_step
    end

    delegate :previous_step, to: :wizard_path_history

    def configure_additional_conditions(conditions)
      conditions.each_with_index do |condition, index|
        instance_variable_set "@further_condition_#{index + 1}", condition
      end
    end

  private

    def course_option_details
      OfferedCourseOptionDetailsCheck.new(provider_id: provider_id,
                                          course_id: course_id,
                                          course_option_id: course_option_id,
                                          study_mode: study_mode).validate!
    rescue OfferedCourseOptionDetailsCheck::InvalidStateError => e
      errors.add(:base, e.message)
    end

    def save_and_go_to_next_step(step)
      attrs = { provider_id: available_providers.first.id } if step.eql?(:providers)
      attrs = { course_id: available_courses.first.id } if step.eql?(:courses)
      attrs = { study_mode: available_study_modes.first } if step.eql?(:study_modes)
      attrs = { course_option_id: available_course_options.first.id } if step.eql?(:locations)

      assign_attributes(last_saved_state.deep_merge(attrs))
      save_state!

      next_step(step)
    end

    def query_service
      @query_service ||= GetChangeOfferOptions.new(
        user: ProviderUser.find(provider_user_id),
        current_course: ApplicationChoice.find(application_choice_id).offered_course,
      )
    end

    def available_study_modes
      query_service.available_study_modes(course: Course.find(course_id))
    end

    def available_course_options
      query_service.available_course_options(course: Course.find(course_id), study_mode: study_mode)
    end

    def available_courses
      query_service.available_courses(provider: Provider.find(provider_id))
    end

    def available_providers
      query_service.available_providers
    end

    def last_saved_state
      saved_state = @state_store.read
      saved_state ? JSON.parse(saved_state) : {}
    end

    def state
      as_json(
        except: %w[state_store errors validation_context query_service course_option wizard_path_history],
      ).to_json
    end

    def update_path_history(attrs)
      @wizard_path_history = WizardPathHistory.new(path_history,
                                                   step: attrs[:current_step].presence,
                                                   action: attrs[:action].presence)
      @wizard_path_history.update
      @path_history = @wizard_path_history.path_history
    end
  end
end
