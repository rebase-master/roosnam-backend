class CreateSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :skills do |t|
      t.string :name
      t.string :slug
      t.string :proficiency_level
      t.float :years_of_experience

      t.timestamps
    end
    add_index :skills, :slug, unique: true
  end
end
