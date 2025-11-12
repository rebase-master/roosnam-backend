class CreateEducation < ActiveRecord::Migration[8.1]
  def change
    create_table :education do |t|
      t.integer :user_id, null: false
      t.string :school_name
      t.string :degree
      t.string :degree_status
      t.integer :start_year
      t.integer :end_year
      t.string :field_of_study
      t.timestamps
    end

    add_foreign_key :education, :users, column: :user_id
    add_index :education, :user_id
  end
end


