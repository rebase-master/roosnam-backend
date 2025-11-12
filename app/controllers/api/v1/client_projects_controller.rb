module Api
  module V1
    class ClientProjectsController < BaseController
      def index
        projects = ClientProject
          .joins(:work_experience)
          .where(work_experiences: { user_id: portfolio_user.id })
          .select(:id, :name, :role, :project_url, :start_date, :end_date, :work_experience_id)
          .order(start_date: :desc, id: :desc)

        render json: projects
      end
    end
  end
end


