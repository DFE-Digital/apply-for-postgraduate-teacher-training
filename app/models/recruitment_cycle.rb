module RecruitmentCycle
  CYCLES = {
    '2021' => '2020 to 2021 (starts 2021)',
    '2020' => '2019 to 2020 (starts 2020)',
  }.freeze

  def self.current_year
    EndOfCycleTimetable.current_year
  end

  def self.next_year
    current_year + 1
  end

  def self.previous_year
    current_year - 1
  end

  def self.years_visible_to_providers
    [current_year, previous_year]
  end

  def self.years_visible_in_support
    [2021, 2020, 2019]
  end

  def self.cycle_name(year = current_year)
    "#{year - 1} to #{year}"
  end
end
