class EducationSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :school_name,
             :degree, :degree_status,
             :field_of_study,
             :start_year, :end_year,
             :certificate_url

  def certificate_url
    return nil unless object.certificate.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      object.certificate,
      only_path: true
    )
  end
end