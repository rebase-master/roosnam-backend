module Api
  module V1
    class ClientReviewsController < BaseController
      def index
        reviews = ClientReview
                    .joins(:client_project)
                    .includes(:client_project)
                    .where(client_projects: { user_id: portfolio_user.id })
                    .order(created_at: :desc)

        render json: reviews, each_serializer: ClientReviewSerializer
      end
    end
  end
end
