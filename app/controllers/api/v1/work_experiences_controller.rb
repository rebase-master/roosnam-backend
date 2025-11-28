module Api
  module V1
    class WorkExperiencesController < BaseController
      def index
        experiences = portfolio_user
                        .work_experiences
                        .includes(:skills)
                        .order(start_date: :desc, id: :desc)

        render json: experiences, each_serializer: WorkExperienceSerializer
      end
    end
  end
end
