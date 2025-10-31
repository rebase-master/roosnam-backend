class CertificationSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :title, :issuer, :issue_date, :expiration_date, :credential_url
end


