class CreateCertifications < ActiveRecord::Migration[8.1]
  def change
    create_table :certifications do |t|
      t.integer :user_id, null: false
      t.text :title
      t.text :issuer
      t.date :issue_date
      t.date :expiration_date
      t.text :credential_url
      t.timestamps
    end

    add_foreign_key :certifications, :users, column: :user_id
    add_index :certifications, :user_id
  end
end


