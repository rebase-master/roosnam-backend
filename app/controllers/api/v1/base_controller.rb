module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session

      private

      # Returns the singleton portfolio user
      def portfolio_user
        @portfolio_user ||= User.first!
      end
    end
  end
end

