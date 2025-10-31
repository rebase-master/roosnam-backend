class ClientReviewSerializer < ActiveModel::Serializer
  attributes :id, :client_name, :client_position, :review_text, :rating, :client_project_id, :created_at
end


