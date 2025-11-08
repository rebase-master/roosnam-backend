class CreateWorkExperiences < ActiveRecord::Migration[8.1]
  def change
    create_table :work_experiences do |t|
      t.references :user, null: false, index: true # adds user_id + index automatically
      t.string :employer_name, null: false
      t.string :job_title
      t.date :start_date
      t.date :end_date
      t.string :city
      t.string :state
      t.string :country
      t.timestamps
    end
    add_foreign_key :work_experiences, :users, column: :user_id
  end
end


