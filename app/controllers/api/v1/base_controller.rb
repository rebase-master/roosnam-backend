module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session

      # Centralized error handling - use StandardError, NOT Exception
      rescue_from StandardError, with: :handle_internal_error
      rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
      rescue_from ActionController::ParameterMissing, with: :handle_bad_request

      private

      def portfolio_user
        @portfolio_user ||= User.first!
      end

      def handle_internal_error(exception)
        Rails.logger.error("API ERROR: #{exception.class} - #{exception.message}")
        Rails.logger.error(exception.backtrace.first(10).join("\n")) if Rails.env.development?

        render json: {
          error: "Internal server error",
          status: :internal_server_error
        }, status: :internal_server_error
      end

      def handle_not_found(exception)
        render json: {
          error: exception.message || "Resource not found",
          status: :not_found
        }, status: :not_found
      end

      def handle_bad_request(exception)
        render json: {
          error: exception.message,
          status: :bad_request
        }, status: :bad_request
      end
    end
  end
end
