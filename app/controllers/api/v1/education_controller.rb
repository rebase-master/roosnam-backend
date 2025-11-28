module Api
  module V1
    class EducationController < BaseController
      def index
        education = portfolio_user
                      .education
                      .with_attached_certificate
                      .order(end_year: :desc, start_year: :desc)

        render json: education, each_serializer: EducationSerializer
      end
    end
  end
end
