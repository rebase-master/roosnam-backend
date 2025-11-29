module Api
  module V1
    class SkillsController < BaseController
      def index
        # Get skills from work experiences belonging to portfolio user
        work_exp_skills = Skill
                            .joins(:work_experience)
                            .where(work_experiences: { user_id: portfolio_user.id })
                            .select('skills.*, work_experiences.employer_name as source_company')

        # Get skills from client projects belonging to portfolio user
        project_skills = Skill
                           .joins('INNER JOIN client_projects_skills ON client_projects_skills.skill_id = skills.id')
                           .joins('INNER JOIN client_projects ON client_projects.id = client_projects_skills.client_project_id')
                           .where(client_projects: { user_id: portfolio_user.id })
                           .select('skills.*, NULL as source_company')

        # Combine skill IDs from both sources and fetch unique skills
        all_skill_ids = (work_exp_skills.pluck(:id) + project_skills.pluck(:id)).uniq

        # Fetch all skills with source_company from work_experience if available
        skills = Skill
                   .left_joins(:work_experience)
                   .where(id: all_skill_ids)
                   .select('skills.*, work_experiences.employer_name as source_company')
                   .order(Arel.sql('skills.years_of_experience DESC NULLS LAST'), :name)

        render json: skills, each_serializer: SkillSerializer
      end
    end
  end
end
