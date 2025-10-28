module Api
  module V1
    class ClientProjectsController < BaseController
      before_action :set_client_project, only: [:show, :update, :destroy]

      def index
        @projects = ClientProject.includes(:company_experience, :project_images, :client_reviews).all
        render json: @projects
      end

      def show
        render json: @project
      end

      def create
        @project = ClientProject.new(project_params)

        if @project.save
          render json: @project, status: :created
        else
          render json: @project.errors, status: :unprocessable_entity
        end
      end

      def update
        if @project.update(project_params)
          render json: @project
        else
          render json: @project.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @project.destroy
        head :no_content
      end

      private

      def set_client_project
        @project = ClientProject.find(params[:id])
      end

      def project_params
        params.require(:client_project).permit(:company_experience_id, :name, :description, :tech_stack, :start_date, :end_date, :role, :project_url)
      end
    end
  end
end

