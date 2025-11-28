class EducationSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :school_name,
             :degree, :degree_status,
             :field_of_study,
             :start_year, :end_year
end


