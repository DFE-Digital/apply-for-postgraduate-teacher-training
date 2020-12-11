class FeatureFlag
  attr_accessor :name, :description, :owner

  def initialize(name:, description:, owner:)
    self.name = name
    self.description = description
    self.owner = owner
  end

  def feature
    Feature.find_or_initialize_by(name: name)
  end

  PERMANENT_SETTINGS = [
    [:banner_about_problems_with_dfe_sign_in, 'Displays a banner to notify users that DfE-Sign is having problems', 'Jake Benilov'],
    [:banner_for_ucas_downtime, 'Displays a banner to notify users that UCAS is having problems', 'Theodor Vararu'],
    [:dfe_sign_in_fallback, 'Use this when DfE Sign-in is down', 'Tijmen Brommet'],
    [:force_ok_computer_to_fail, 'OK Computer implements a health check endpoint, this flag forces it to fail for testing purposes', 'Michael Nacos'],
    [:pilot_open, 'Enables the Apply for Teacher Training service', 'Tijmen Brommet'],
    [:provider_information_banner, 'Displays an information banner for providers on the start page and applications page', 'Ben Swannack'],
    [:deadline_notices, 'Show candidates copy related to end of cycle deadlines', 'Malcolm Baig'],
    [:hold_courses_open, 'Force all courses to appear to have vacancies. Do not enable in production!', 'Duncan Brown'],
  ].freeze

  TEMPORARY_FEATURE_FLAGS = [
    [:efl_section, 'Allow candidates with nationalities other then British or Irish to specify their English as a Foreign Language experience', 'Malcolm Baig'],
    [:export_hesa_data, 'Providers can export applications including HESA data.', 'Steve Laing'],
    [:feedback_prompts, 'Candidates can give feedback while completing their application form', 'David Gisbey'],
    [:multiple_science_gcses, 'Candidates can enter structured data for multiple science GCSEs', 'Toby Retallick'],
    [:multiple_english_gcses, 'Candidates can enter structured data for multiple English GCSEs.', 'Raam Chauhan'],
    [:structured_reasons_for_rejection, 'Allows providers to give specific reasons for rejecting an application', 'Steve Laing'],
    [:sync_from_public_teacher_training_api, 'Pull data from the public Teacher training API as well as the old "Find" API', 'Duncan Brown'],
    [:provider_activity_log, 'Show provider users a log of all application activity', 'Michael Nacos'],
    [:find_feedback, 'Candidate can provide feedback on the Find service', 'David Gisbey'],
  ].freeze

  FEATURES = (PERMANENT_SETTINGS + TEMPORARY_FEATURE_FLAGS).map { |name, description, owner|
    [name, FeatureFlag.new(name: name, description: description, owner: owner)]
  }.to_h.with_indifferent_access.freeze

  def self.activate(feature_name)
    raise unless feature_name.in?(FEATURES)

    sync_with_database(feature_name, true)
  end

  def self.deactivate(feature_name)
    raise unless feature_name.in?(FEATURES)

    sync_with_database(feature_name, false)
  end

  def self.active?(feature_name)
    raise unless feature_name.in?(FEATURES)

    FEATURES[feature_name].feature.active?
  end

  def self.sync_with_database(feature_name, active)
    feature = Feature.find_or_initialize_by(name: feature_name)
    feature.active = active
    feature.save!
  end
end
