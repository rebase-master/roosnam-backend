module Api
  module V1
    class SkillsController < BaseController
      def index
        skills = Skill.select(:id, :name, :slug).order(:name)
        render json: skills
      end
    end
  end
end


