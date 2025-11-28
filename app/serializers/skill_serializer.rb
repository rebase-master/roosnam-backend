class SkillSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :proficiency_level, :years_of_experience

  def proficiency_level
    object.proficiency_level || infer_proficiency
  end

  private

  def infer_proficiency
    years = object.years_of_experience || 0
    case years
    when 0..1 then 'beginner'
    when 1..3 then 'intermediate'
    when 3..6 then 'advanced'
    else 'expert'
    end
  end
end
