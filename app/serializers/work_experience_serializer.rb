class WorkExperienceSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :employer_name,
             :job_title, :start_date, :end_date,
             :city, :state, :country

  has_many :skills
end

