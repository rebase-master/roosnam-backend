module Api
  module V1
    class EducationController < BaseController
      def index
        education = Education
          .where(user_id: portfolio_user.id)
          .order(start_year: :desc, id: :desc)

        render json: education
      rescue Exception => e
        Rails.logger.error("API ERROR: An error occurred: #{e.message}")
        render json: { status: :not_found, error: "Internal server error" }
      end
    end
  end
end


