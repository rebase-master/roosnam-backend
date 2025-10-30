module Api
  module V1
    class WorksController < BaseController
      def index
        works = ClientProject
          .select(:id, :name, :role, :project_url, :start_date, :end_date, :company_experience_id)
          .order(start_date: :desc, id: :desc)

        render json: works.map { |w|
          {
            id: w.id,
            title: w.name,
            role: w.role,
            url: w.project_url,
            start_date: w.start_date,
            end_date: w.end_date
          }
        }
      end
    end
  end
end


