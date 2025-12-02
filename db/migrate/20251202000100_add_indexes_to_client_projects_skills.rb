class AddIndexesToClientProjectsSkills < ActiveRecord::Migration[8.1]
  def change
    add_index :client_projects_skills,
              %i[client_project_id skill_id],
              unique: true,
              name: 'index_client_projects_skills_on_project_and_skill'

    add_index :client_projects_skills,
              :skill_id,
              name: 'index_client_projects_skills_on_skill_id'
  end
end


