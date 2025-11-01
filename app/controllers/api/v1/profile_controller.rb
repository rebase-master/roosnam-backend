module Api
  module V1
    class ProfileController < BaseController
      def show
        render json: portfolio_user, serializer: UserProfileSerializer
      end
    end
  end
end

