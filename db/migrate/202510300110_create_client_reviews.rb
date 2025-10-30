class CreateClientReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :client_reviews do |t|
      t.integer :client_project_id, null: false
      t.string :client_name
      t.string :client_position
      t.text :review_text
      t.integer :rating
      t.timestamps
    end

    add_foreign_key :client_reviews, :client_projects, column: :client_project_id
    add_index :client_reviews, :client_project_id
  end
end


