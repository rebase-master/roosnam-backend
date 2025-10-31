class ExperienceSkillSerializer < ActiveModel::Serializer
  attributes :id, :skill_id, :company_experience_id, :proficiency_level, :years_of_experience, :notes
end


