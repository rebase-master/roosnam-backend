module Api
  module V1
    class CompanyExperiencesController < BaseController

      def index
        experiences = CompanyExperience
          .where(user_id: portfolio_user.id)
          .select(:id, :user_id, :company_id, :company_text, :title, :start_date, :end_date, :description)
          .order(start_date: :desc, id: :desc)

        render json: experiences
      end
    end
  end
end


