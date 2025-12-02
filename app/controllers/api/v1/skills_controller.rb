module Api
  module V1
    class SkillsController < BaseController
      def index
        skills = Skill
                   .left_joins(:work_experience)
                   .joins(<<~SQL.squish)
                     LEFT JOIN project_skills
                       ON project_skills.skill_id = skills.id
                     LEFT JOIN client_projects
                       ON client_projects.id = project_skills.client_project_id
                   SQL
                   .where(<<~SQL.squish, user_id: portfolio_user.id)
                     work_experiences.user_id = :user_id
                     OR client_projects.user_id = :user_id
                   SQL
                   .select('DISTINCT skills.*, work_experiences.employer_name AS source_company')
                   .order(Arel.sql('skills.years_of_experience DESC NULLS LAST'), :name)

        render json: skills, each_serializer: SkillSerializer
      end
    end
  end
end
