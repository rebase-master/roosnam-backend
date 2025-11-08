class CreateClientProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :client_projects do |t|
      t.integer :work_experience_id, null: false
      t.string :name
      t.text :description
      t.string :tech_stack
      t.date :start_date
      t.date :end_date
      t.string :role
      t.string :project_url
      t.timestamps
    end

    add_foreign_key :client_projects, :work_experiences, column: :work_experience_id
    add_index :client_projects, :work_experience_id
  end
end


