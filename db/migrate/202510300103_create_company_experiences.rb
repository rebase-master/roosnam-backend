class CreateCompanyExperiences < ActiveRecord::Migration[8.1]
  def change
    create_table :company_experiences do |t|
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

    add_foreign_key :company_experiences, :users, column: :user_id
    add_foreign_key :company_experiences, :companies, column: :company_id
    add_index :company_experiences, :user_id
    add_index :company_experiences, :company_id
  end
end


