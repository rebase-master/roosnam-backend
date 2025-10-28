class CreateClientReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :client_reviews do |t|
      t.references :client_project, null: false, foreign_key: true
      t.string :client_name
      t.string :client_position
      t.text :review_text
      t.integer :rating, null: true

      t.timestamps
    end
  end
end
