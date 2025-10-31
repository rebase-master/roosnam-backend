class ClientProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :role, :project_url, :start_date, :end_date, :company_experience_id
end


