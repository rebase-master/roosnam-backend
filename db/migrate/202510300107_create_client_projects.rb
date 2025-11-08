class CreateClientProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :client_projects do |t|
      t.references :user, null: false, index: true
      t.string :client_name
      t.string :client_website
      t.string :name, null: false
      t.text :description, null: false
      t.string :tech_stack
      t.date :start_date
      t.date :end_date
      t.string :role
      t.string :project_url
      t.timestamps
    end

    add_foreign_key :client_projects, :users
  end
end
