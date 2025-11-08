module Api
  module V1
    class WorksController < BaseController
      def index
        works = ClientProject
          .joins(:work_experience)
          .where(work_experiences: { user_id: portfolio_user.id })
          .select(:id, :name, :role, :project_url, :start_date, :end_date, :work_experience_id)
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


