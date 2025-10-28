class CreateCompanyExperiences < ActiveRecord::Migration[8.1]
  def change
    create_table :company_experiences do |t|
      t.references :company, null: false, foreign_key: true
      t.string :title
      t.date :joining_date
      t.date :leaving_date, null: true
      t.text :description
      t.string :experience_letter
      t.string :relieving_letter

      t.timestamps
    end
  end
end
