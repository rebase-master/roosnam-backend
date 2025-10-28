module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session

      # Public read-only by default; write actions require admin
      before_action :authenticate_admin!, except: [:index, :show]

      private

      def authenticate_admin!
        unless user_signed_in?
          render json: { error: 'Unauthorized' }, status: :unauthorized and return
        end

        unless current_user.admin?
          render json: { error: 'Forbidden' }, status: :forbidden
        end
      end
    end
  end
end

