class CreateExperienceSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :experience_skills do |t|
      t.integer :skill_id, null: false
      t.integer :work_experience_id, null: false
      t.string :proficiency_level
      t.float :years_of_experience
      t.text :notes
      t.timestamps
    end

    add_foreign_key :experience_skills, :skills, column: :skill_id
    add_foreign_key :experience_skills, :work_experiences, column: :work_experience_id
    add_index :experience_skills, :skill_id
    add_index :experience_skills, :work_experience_id
  end
end


