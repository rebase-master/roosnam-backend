class ExperienceSkill < ApplicationRecord
  belongs_to :skill
  belongs_to :company_experience

  enum proficiency_level: {
    beginner: 'Beginner',
    intermediate: 'Intermediate',
    advanced: 'Advanced'
  }, _suffix: true, _scopes: true

  validates :years_of_experience, numericality: { allow_nil: true, greater_than_or_equal_to: 0 }
end


