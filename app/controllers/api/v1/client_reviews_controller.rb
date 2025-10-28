module Api
  module V1
    class ClientReviewsController < BaseController
      before_action :set_client_review, only: [:show, :update, :destroy]

      def index
        @reviews = ClientReview.includes(:client_project).all
        render json: @reviews
      end

      def show
        render json: @review
      end

      def create
        @review = ClientReview.new(review_params)

        if @review.save
          render json: @review, status: :created
        else
          render json: @review.errors, status: :unprocessable_entity
        end
      end

      def update
        if @review.update(review_params)
          render json: @review
        else
          render json: @review.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @review.destroy
        head :no_content
      end

      private

      def set_client_review
        @review = ClientReview.find(params[:id])
      end

      def review_params
        params.require(:client_review).permit(:client_project_id, :client_name, :client_position, :review_text, :rating)
      end
    end
  end
end

