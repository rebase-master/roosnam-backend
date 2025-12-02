module Api
  module V1
    class SkillsController < BaseController
      def index
        skills = Skill.for_portfolio_user(portfolio_user.id)
        render json: skills, each_serializer: SkillSerializer
      end
    end
  end
end
