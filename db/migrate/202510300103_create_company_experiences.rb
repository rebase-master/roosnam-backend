class CreateWorkExperiences < ActiveRecord::Migration[8.1]
  def change
    create_table :work_experiences do |t|
      t.integer :user_id, null: false
      t.integer :company_id
      t.text :company_text
      t.string :title
      t.date :start_date
      t.date :end_date
      t.text :description
      t.string :experience_letter
      t.string :relieving_letter
      t.timestamps
    end

    add_foreign_key :work_experiences, :users, column: :user_id
    add_foreign_key :work_experiences, :companies, column: :company_id
    add_index :work_experiences, :user_id
    add_index :work_experiences, :company_id
  end
end


