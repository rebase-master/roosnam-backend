class RenameCompanyExperiencesToWorkExperiences < ActiveRecord::Migration[8.1]
  def change
    # Rename the table
    rename_table :company_experiences, :work_experiences

    # Rename foreign key columns
    rename_column :client_projects, :company_experience_id, :work_experience_id
    rename_column :experience_skills, :company_experience_id, :work_experience_id

    # Rename foreign key constraints
    remove_foreign_key :work_experiences, :companies
    remove_foreign_key :work_experiences, :users

    add_foreign_key :client_projects, :work_experiences, column: :work_experience_id
    add_foreign_key :experience_skills, :work_experiences, column: :work_experience_id
    add_foreign_key :work_experiences, :companies, column: :company_id
    add_foreign_key :work_experiences, :users, column: :user_id

    # Rename indexes
    rename_index :client_projects, :index_client_projects_on_company_experience_id, :index_client_projects_on_work_experience_id
    rename_index :experience_skills, :index_experience_skills_on_company_experience_id, :index_experience_skills_on_work_experience_id
    rename_index :work_experiences, :index_company_experiences_on_user_id, :index_work_experiences_on_user_id
    rename_index :work_experiences, :index_company_experiences_on_company_id, :index_work_experiences_on_company_id
  end
end
