module Api
  module V1
    class ClientProjectsController < BaseController
      def index
        projects = ClientProject
          .joins(:company_experience)
          .where(company_experiences: { user_id: portfolio_user.id })
          .select(:id, :name, :role, :project_url, :start_date, :end_date, :company_experience_id)
          .order(start_date: :desc, id: :desc)

        render json: projects
      end
    end
  end
end


