class RemoveClientProjectsSkillsTable < ActiveRecord::Migration[8.1]
  def up
    # Migrate existing HABTM join data into the canonical project_skills table.
    # Use INSERT OR IGNORE semantics to avoid violating the unique index on
    # [:client_project_id, :skill_id].
    execute <<~SQL
      INSERT OR IGNORE INTO project_skills (client_project_id, skill_id, created_at, updated_at)
      SELECT client_project_id, skill_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM client_projects_skills
    SQL

    drop_table :client_projects_skills
  end

  def down
    create_table :client_projects_skills, id: false do |t|
      t.integer :client_project_id, null: false
      t.integer :skill_id, null: false
    end
  end
end


