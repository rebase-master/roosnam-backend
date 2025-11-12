class CreateSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :skills do |t|
      t.references :work_experience, foreign_key: true, null: true
      t.string :name, null: false
      t.string :proficiency_level
      t.decimal :years_of_experience, precision: 3, scale: 1
      t.string :slug
      t.timestamps
    end

    add_index :skills, :slug, unique: true
  end
end


