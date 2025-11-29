class SkillSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :proficiency_level, :years_of_experience, :source_company

  def source_company
    # This attribute is dynamically added by the SQL query in SkillsController
    object.try(:source_company) || object.work_experience&.employer_name
  end
end
