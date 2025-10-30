class ExperienceSkill < ApplicationRecord
  belongs_to :skill
  belongs_to :company_experience

  enum :proficiency_level, {
    beginner:  'Beginner',
    intermediate: 'Intermediate',
    advanced:  'Advanced'
  }, suffix: true, scopes: true, enum_type: :string


  validates :years_of_experience, numericality: { allow_nil: true, greater_than_or_equal_to: 0 }
end


