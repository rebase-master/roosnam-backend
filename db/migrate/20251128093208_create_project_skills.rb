class CreateProjectSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :project_skills do |t|
      t.references :client_project, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true

      t.timestamps
    end

    add_index :project_skills, [:client_project_id, :skill_id], unique: true
  end
end