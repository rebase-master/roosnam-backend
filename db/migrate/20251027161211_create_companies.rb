class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :location
      t.string :industry
      t.integer :employee_count
      t.string :website
      t.string :logo_url

      t.timestamps
    end
  end
end
