class ToeflQualification < ApplicationRecord
  has_one :english_proficiency, as: :efl_qualification

  def name
    'TOEFL'
  end

  def grade
    total_score
  end
end
