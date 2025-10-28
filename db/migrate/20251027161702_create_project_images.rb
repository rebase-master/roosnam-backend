class CreateProjectImages < ActiveRecord::Migration[8.1]
  def change
    create_table :project_images do |t|
      t.references :client_project, null: false, foreign_key: true
      t.string :image_url
      t.string :caption, null: true
      t.integer :position

      t.timestamps
    end
  end
end
