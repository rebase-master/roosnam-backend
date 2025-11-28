module Api
  module V1
    class ClientReviewsController < BaseController

      def index
        reviews = ClientReview
          .joins(:client_project)
          .where(client_project: { user_id: portfolio_user.id })
          .order(id: :desc)

        render json: reviews
      rescue Exception => e
        Rails.logger.error("API ERROR: An error occurred: #{e.message}")
        render json: { status: :not_found, error: "Internal server error" }
      end
    end
  end
end


