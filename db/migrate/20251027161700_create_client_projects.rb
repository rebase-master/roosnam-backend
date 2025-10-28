class CreateClientProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :client_projects do |t|
      t.references :company_experience, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.string :tech_stack, null: true
      t.date :start_date, null: true
      t.date :end_date, null: true
      t.string :role
      t.string :project_url, null: true

      t.timestamps
    end
  end
end
