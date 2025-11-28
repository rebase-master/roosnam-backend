module Api
  module V1
    class ProfileController < BaseController
      def show
        render json: portfolio_user
      rescue Exception => e
        Rails.logger.error("API ERROR: An error occurred: #{e.message}")
        render json: { status: :not_found, error: "Internal server error" }
      end
    end
  end
end

