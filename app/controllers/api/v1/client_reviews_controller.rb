module Api
  module V1
    class ClientReviewsController < BaseController

      def index
        reviews = ClientReview
          .joins(client_project: :company_experience)
          .where(company_experiences: { user_id: portfolio_user.id })
          .select(:id, :client_name, :client_position, :review_text, :rating, :client_project_id, :created_at)
          .order(id: :desc)

        render json: reviews
      end
    end
  end
end


