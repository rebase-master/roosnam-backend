class ExperienceSkill < ApplicationRecord
  belongs_to :skill
  belongs_to :company_experience

  validates :skill_id, uniqueness: { scope: :company_experience_id }
end

