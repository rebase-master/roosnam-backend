module Api
  module V1
    class ClientProjectsController < BaseController
      def index
        projects = portfolio_user
                     .client_projects
                     .includes(:skills, :client_reviews)
                     .with_attached_project_images
                     .order(start_date: :desc, id: :desc)

        render json: projects, each_serializer: ClientProjectSerializer
      end

      def show
        project = portfolio_user.client_projects.find(params[:id])
        render json: project, serializer: ClientProjectSerializer
      end
    end
  end
end
