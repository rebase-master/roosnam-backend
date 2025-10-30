class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :location
      t.text :description
      t.string :industry
      t.string :employee_count_range
      t.string :website
      t.string :logo_url
      t.integer :founded_year
      t.boolean :verified, null: false, default: false
      t.timestamps
    end

    add_index :companies, [:name, :location, :website], unique: true, name: "index_companies_on_name_location_website"
  end
end


