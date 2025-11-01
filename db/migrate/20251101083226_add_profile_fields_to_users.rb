class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    # Personal Information
    add_column :users, :full_name, :string
    add_column :users, :display_name, :string
    add_column :users, :headline, :string
    add_column :users, :bio, :text
    add_column :users, :tagline, :string
    add_column :users, :phone, :string
    add_column :users, :location, :string
    add_column :users, :timezone, :string

    # Professional
    add_column :users, :years_of_experience, :integer
    add_column :users, :availability_status, :string, default: 'available'
    add_column :users, :hourly_rate, :string  # Format: "USD 50/hr"

    # Social Links (TEXT storing JSON - SQLite compatible)
    add_column :users, :social_links, :text

    # Portfolio Settings (TEXT storing JSON)
    add_column :users, :portfolio_settings, :text

    # SEO
    add_column :users, :seo_title, :string
    add_column :users, :seo_description, :text

    # Metadata
    add_column :users, :profile_completeness, :integer, default: 0

    # Indexes
    add_index :users, :full_name
    add_index :users, :location
  end
end
