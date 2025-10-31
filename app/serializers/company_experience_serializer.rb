class CompanyExperienceSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :company_id, :company_text, :title, :start_date, :end_date, :description
end


