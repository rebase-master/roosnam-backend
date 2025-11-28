module Api
  module V1
    class ClientProjectsController < BaseController
      def index
        projects = ClientProject
          .where(user_id: portfolio_user.id )
          .order(start_date: :desc, id: :desc)

        render json: projects
      rescue Exception => e
        Rails.logger.error("API ERROR: An error occurred: #{e.message}")
        render json: { status: :not_found, error: "Internal server error" }
      end
    end
  end
end


