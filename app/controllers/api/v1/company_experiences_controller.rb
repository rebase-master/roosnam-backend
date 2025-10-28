module Api
  module V1
    class CompanyExperiencesController < BaseController
      before_action :set_company_experience, only: [:show, :update, :destroy]

      def index
        @experiences = CompanyExperience.includes(:company, :skills).all
        render json: @experiences
      end

      def show
        render json: @experience
      end

      def create
        @experience = CompanyExperience.new(experience_params)

        if @experience.save
          render json: @experience, status: :created
        else
          render json: @experience.errors, status: :unprocessable_entity
        end
      end

      def update
        if @experience.update(experience_params)
          render json: @experience
        else
          render json: @experience.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @experience.destroy
        head :no_content
      end

      private

      def set_company_experience
        @experience = CompanyExperience.find(params[:id])
      end

      def experience_params
        params.require(:company_experience).permit(:company_id, :title, :joining_date, :leaving_date, :description, :experience_letter, :relieving_letter)
      end
    end
  end
end

