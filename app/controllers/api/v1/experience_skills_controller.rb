module Api
  module V1
    class ExperienceSkillsController < BaseController

      def index
        links = ExperienceSkill
          .joins(:company_experience)
          .where(company_experiences: { user_id: portfolio_user.id })
          .select(:id, :skill_id, :company_experience_id, :proficiency_level, :years_of_experience, :notes)
          .order(id: :desc)

        render json: links
      end
    end
  end
end


