class CreateJoinTableClientProjectsSkills < ActiveRecord::Migration[8.1]
  def change
    create_join_table :client_projects, :skills do |t|
      # t.index [:client_project_id, :skill_id]
      # t.index [:skill_id, :client_project_id]
    end
  end
end
