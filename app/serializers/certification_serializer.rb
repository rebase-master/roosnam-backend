class CertificationSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :title, :issuer,
             :issue_date, :expiration_date, :credential_url,
             :document_url,
             :is_expired

  def document_url
    return nil unless object.document.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      object.document,
      only_path: true
    )
  end

  def is_expired
    return false if object.expiration_date.nil?
    object.expiration_date < Date.current
  end
end