class ClientProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :role,
             :project_url, :start_date, :end_date,
             :user_id, :client_name, :client_website,
             :description, :tech_stack
end


