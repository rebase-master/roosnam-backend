module Api
  module V1
    class CertificationsController < BaseController
      def index
        certs = Certification
          .where(user_id: portfolio_user.id)
          .select(:id, :user_id, :title, :issuer, :issue_date, :expiration_date, :credential_url)
          .order(issue_date: :desc, id: :desc)

        render json: certs
      end
    end
  end
end


