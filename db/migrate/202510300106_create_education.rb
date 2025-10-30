class CreateEducation < ActiveRecord::Migration[8.1]
  def change
    create_table :education do |t|
      t.integer :user_id, null: false
      t.text :institution
      t.text :degree
      t.text :field_of_study
      t.integer :start_year
      t.integer :end_year
      t.text :grade
      t.text :description
      t.timestamps
    end

    add_foreign_key :education, :users, column: :user_id
    add_index :education, :user_id
  end
end


