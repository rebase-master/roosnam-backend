class ClientReviewSerializer < ActiveModel::Serializer
  attributes :id, :reviewer_name, :reviewer_position, :reviewer_company, :review_text, :rating, :client_project_id, :created_at, :reviewer_display_name

  def reviewer_display_name
    object.reviewer_display_name
  end
end