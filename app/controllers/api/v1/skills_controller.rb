module Api
  module V1
    class SkillsController < BaseController
      def index
        # Get skills from work experiences belonging to portfolio user
        skills = Skill
                   .joins(:work_experience)
                   .where(work_experiences: { user_id: portfolio_user.id })
                   .select('skills.*, work_experiences.employer_name as source_company')
                   .order(years_of_experience: :desc, name: :asc)

        render json: skills, each_serializer: SkillSerializer
      end
    end
  end
end
