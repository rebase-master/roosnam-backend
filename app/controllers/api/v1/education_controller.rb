module Api
  module V1
    class EducationController < BaseController
      def index
        records = Education
          .where(user_id: portfolio_user.id)
          .select(:id, :user_id, :institution, :degree, :field_of_study, :start_year, :end_year, :grade, :description)
          .order(start_year: :desc, id: :desc)

        render json: records
      end
    end
  end
end


