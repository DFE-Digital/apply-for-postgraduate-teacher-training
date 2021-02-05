class ApplicationQualification < ApplicationRecord
  include PublishedInAPI

  EXPECTED_DEGREE_DATA = %i[
    qualification_type
    subject
    institution_name
    grade
    start_year
    award_year
  ].freeze

  EXPECTED_GCSE_DATA = %i[
    qualification_type
    subject
    award_year
  ].freeze

  EXPECTED_OTHER_QUALIFICATION_DATA = %i[
    qualification_type
    subject
    grade
    award_year
  ].freeze

  EXPECTED_INTERNATIONAL_OTHER_QUALIFICATION_DATA = %i[
    qualification_type
    non_uk_qualification_type
    institution_country
    award_year
  ].freeze

  # Science GCSE may have any of the following subject variants
  SCIENCE = 'science'.freeze
  SCIENCE_SINGLE_AWARD = 'science single award'.freeze
  SCIENCE_DOUBLE_AWARD = 'science double award'.freeze
  SCIENCE_TRIPLE_AWARD = 'science triple award'.freeze

  belongs_to :application_form, touch: true

  scope :degrees, -> { where level: 'degree' }
  scope :gcses, -> { where level: 'gcse' }

  enum level: {
    degree: 'degree',
    gcse: 'gcse',
    other: 'other',
  }

  enum comparable_uk_degree: {
    bachelor_ordinary_degree: 'bachelor_ordinary_degree',
    bachelor_honours_degree: 'bachelor_honours_degree',
    postgraduate_certificate_or_diploma: 'postgraduate_certificate_or_diploma',
    masters_degree: 'masters_degree',
    doctor_of_philosophy: 'doctor_of_philosophy',
    post_doctoral_award: 'post_doctoral_award',
  }

  audited associated_with: :application_form

  after_save :set_public_id

  def missing_qualification?
    qualification_type == 'missing'
  end

  def incomplete_degree_information?
    return false unless degree?
    return true if predicted_grade.nil?

    return true if EXPECTED_DEGREE_DATA.any? do |field_name|
      send(field_name).blank?
    end

    false
  end

  def incomplete_gcse_information?
    return true if grade.nil? && constituent_grades.nil?

    return true if EXPECTED_GCSE_DATA.any? do |field_name|
      send(field_name).blank?
    end

    false
  end

  def incomplete_other_qualification?
    if qualification_type == 'non_uk'
      incomplete_international_data?
    elsif other?
      incomplete_other_qualification_data?
    else
      false
    end
  end

  def incomplete_international_data?
    EXPECTED_INTERNATIONAL_OTHER_QUALIFICATION_DATA.any? do |field_name|
      send(field_name).blank?
    end
  end

  def incomplete_other_qualification_data?
    EXPECTED_OTHER_QUALIFICATION_DATA.reject { |k| k == :grade }.any? do |field_name|
      send(field_name).blank?
    end
  end

  def have_naric_reference
    if naric_reference.present?
      'Yes'
    elsif naric_reference.nil? && grade.present?
      'No'
    end
  end

  def set_grade
    case grade
    when 'n/a'
      'not_applicable'
    when 'unknown'
      'unknown'
    else
      'other'
    end
  end

  def set_other_grade
    grade if grade != 'n/a' && grade != 'unknown'
  end

  def completed?
    !predicted_grade?
  end

  def composite_equivalency_details
    details = [
      ("Naric: #{naric_reference}" if naric_reference),
      comparable_uk_qualification || comparable_uk_degree,
      equivalency_details,
    ].compact.join(' - ')

    details.strip if details.present?
  end

private

  def set_public_id
    if constituent_grades.present?
      set_public_ids_for_constituent_grades
    elsif public_id.blank?
      update_column(:public_id, next_available_public_id)
    end
  end

  def set_public_ids_for_constituent_grades
    grades_with_ids = constituent_grades.transform_values do |grade|
      next grade if grade['public_id'].present?

      grade.merge({ public_id: next_available_public_id })
    end

    update_column(:constituent_grades, grades_with_ids)
  end

  def next_available_public_id
    ActiveRecord::Base.nextval(:qualifications_public_id_seq)
  end
end
