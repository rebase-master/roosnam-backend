class WorkExperienceSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :employer_name,
             :job_title, :start_date, :end_date,
             :city, :state, :country,
             :is_current, :duration_months

  has_many :skills, serializer: SkillSerializer

  def is_current
    object.current?
  end

  def duration_months
    object.duration_in_months
  end
end