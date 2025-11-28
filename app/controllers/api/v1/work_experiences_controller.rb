module Api
  module V1
    class WorkExperiencesController < BaseController

      def index
        experiences = WorkExperience
          .where(user_id: portfolio_user.id)
          .order(start_date: :desc, id: :desc)

        render json: experiences
      rescue Exception => e
        Rails.logger.error("API ERROR: An error occurred: #{e.message}")
        render json: { status: :not_found, error: "Internal server error" }
      end
    end
  end
end

