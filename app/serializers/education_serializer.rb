class EducationSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :institution, :degree, :field_of_study, :start_year, :end_year, :grade, :description
end


