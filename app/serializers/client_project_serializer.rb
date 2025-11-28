class ClientProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :client_name, :client_website,
             :project_url, :role, :tech_stack, :start_date, :end_date,
             :image_urls

  has_many :skills, serializer: SkillSerializer

  def image_urls
    return [] unless object.project_images.attached?

    object.project_images.map do |image|
      Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true)
    end
  end

  def tech_stack
    object.tech_stack_array
  end
end
