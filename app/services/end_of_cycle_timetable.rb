class EndOfCycleTimetable
  def self.between_cycles?(phase)
    phase == 'apply_1' ? between_cycles_apply_1? : between_cycles_apply_2?
  end

  def self.show_apply_1_deadline_banner?
    Time.zone.now < date(:apply_1_deadline).end_of_day
  end

  def self.show_apply_2_deadline_banner?
    Time.zone.now < date(:apply_2_deadline).end_of_day
  end

  def self.stop_applications_to_unavailable_course_options?
    Time.zone.now > date(:stop_applications_to_unavailable_course_options).end_of_day &&
      Time.zone.now < date(:apply_reopens).beginning_of_day
  end

  def self.apply_1_deadline
    date(:apply_1_deadline)
  end

  def self.stop_applications_to_unavailable_course_options
    date(:stop_applications_to_unavailable_course_options)
  end

  def self.apply_2_deadline
    date(:apply_2_deadline)
  end

  def self.find_closes
    date(:find_closes)
  end

  def self.find_reopens
    date(:find_reopens)
  end

  def self.find_down?
    Time.zone.now.between?(find_closes.end_of_day, find_reopens.beginning_of_day)
  end

  def self.apply_reopens
    date(:apply_reopens)
  end

  def self.between_cycles_apply_1?
    Time.zone.now > date(:apply_1_deadline).end_of_day &&
      Time.zone.now < date(:apply_reopens).beginning_of_day
  end

  def self.between_cycles_apply_2?
    Time.zone.now > date(:apply_2_deadline).end_of_day &&
      Time.zone.now < date(:apply_reopens).beginning_of_day
  end

  def self.date(name)
    schedule = schedules.fetch(current_cycle_schedule)
    schedule.fetch(name)
  end

  def self.current_cycle_schedule
    return :real unless HostingEnvironment.test_environment? || HostingEnvironment.sandbox_mode?
    return :today_is_between_cycles if FeatureFlag.active?(:simulate_time_between_cycles)
    return :today_is_mid_cycle if FeatureFlag.active?(:simulate_time_mid_cycle)
    return :today_applications_are_unavailable_to_stopped_courses if FeatureFlag.active?(:simulate_stop_applications_to_unavailable_course_options)

    :real
  end

  def self.next_cycle_year
    RecruitmentCycle.current_year + 1
  end

  def self.schedules
    {
      real: {
        apply_1_deadline: Date.new(2020, 8, 24),
        stop_applications_to_unavailable_course_options: Date.new(2020, 9, 7),
        apply_2_deadline: Date.new(2020, 9, 18),
        find_closes: Date.new(2020, 9, 19),
        find_reopens: Date.new(2020, 10, 3),
        apply_reopens: Date.new(2020, 10, 13),
      },
      today_is_between_cycles: {
        apply_1_deadline: 5.days.ago.to_date,
        stop_applications_to_unavailable_course_options: 3.days.ago.to_date,
        apply_2_deadline: 2.days.ago.to_date,
        find_closes: 1.day.ago.to_date,
        find_reopens: 5.days.from_now.to_date,
        apply_reopens: Date.new(2020, 10, 13) > Time.zone.today ? Date.new(2020, 10, 13) : (Time.zone.today + 1),
      },
      today_applications_are_unavailable_to_stopped_courses: {
        apply_1_deadline: 5.days.ago.to_date,
        stop_applications_to_unavailable_course_options: 1.day.ago.to_date,
        apply_2_deadline: 1.day.from_now.to_date,
        find_closes: 2.days.from_now.to_date,
        find_reopens: 4.days.from_now.to_date,
        apply_reopens: 4.days.from_now.to_date,
      },
      today_is_mid_cycle: {
        apply_1_deadline: 20.weeks.from_now.to_date,
        stop_applications_to_unavailable_course_options: 20.weeks.from_now.to_date,
        apply_2_deadline: 22.weeks.from_now.to_date,
        find_closes: 22.weeks.from_now.to_date,
        find_reopens: 25.weeks.from_now.to_date,
        apply_reopens: 26.weeks.from_now.to_date,
      },
    }
  end

  def self.current_cycle?(application_form)
    application_form.application_choices.includes(:course).all? do |application_choice|
      application_choice.course.recruitment_cycle_year == RecruitmentCycle.current_year
    end
  end
end
