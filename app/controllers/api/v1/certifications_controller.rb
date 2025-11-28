module Api
  module V1
    class CertificationsController < BaseController
      def index
        certs = Certification
          .where(user_id: portfolio_user.id)
          .select(:id, :user_id, :title, :issuer, :issue_date, :expiration_date, :credential_url)
          .order(issue_date: :desc, id: :desc)

        render json: certs
      rescue Exception => e
        Rails.logger.error("API ERROR: An error occurred: #{e.message}")
        render json: { status: :not_found, error: "Internal server error" }
      end
    end
  end
end


