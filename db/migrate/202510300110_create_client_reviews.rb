class CreateClientReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :client_reviews do |t|
      t.references :client_project, null: false, index: true
      t.references :user, null: false, index: true
      t.string :reviewer_name
      t.string :reviewer_position
      t.string :reviewer_company
      t.text :review_text, null: false
      t.integer :rating, limit: 1
      t.timestamps
    end

    add_foreign_key :client_reviews, :client_projects
    add_foreign_key :client_reviews, :users
  end
end


