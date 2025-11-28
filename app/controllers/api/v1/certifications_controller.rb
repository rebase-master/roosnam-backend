module Api
  module V1
    class CertificationsController < BaseController
      def index
        certifications = portfolio_user
                           .certifications
                           .with_attached_document
                           .order(issue_date: :desc)

        render json: certifications, each_serializer: CertificationSerializer
      end
    end
  end
end
