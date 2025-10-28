class CreateExperienceSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :experience_skills do |t|
      t.references :skill, null: false, foreign_key: true
      t.references :company_experience, null: false, foreign_key: true
      t.text :notes

      t.timestamps
    end
  end
end
