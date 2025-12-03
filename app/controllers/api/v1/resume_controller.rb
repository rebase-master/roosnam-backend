module Api
  module V1
    class ResumeController < BaseController
      # GET /api/v1/resume
      # Returns a redirect/stream of the current portfolio user's resume
      def show
        user = portfolio_user.reload
        unless user.resume.attached?
          return render json: { error: "Resume not found", status: :not_found }, status: :not_found
        end

        redirect_to Rails.application.routes.url_helpers.rails_blob_url(
          user.resume,
          host: request.host,
          port: request.port,
          disposition: :inline
        )
      end
    end
  end
end
