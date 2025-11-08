# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_11_08_052206) do
  create_table "attachments", force: :cascade do |t|
    t.string "caption"
    t.text "content_type"
    t.datetime "created_at", null: false
    t.text "filename"
    t.integer "owner_id", null: false
    t.text "owner_type", null: false
    t.integer "position"
    t.bigint "size_bytes"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["owner_type", "owner_id"], name: "index_attachments_on_owner_type_and_owner_id"
  end

  create_table "certifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "credential_url"
    t.date "expiration_date"
    t.date "issue_date"
    t.text "issuer"
    t.text "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_certifications_on_user_id"
  end

  create_table "client_projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.date "end_date"
    t.string "name"
    t.string "project_url"
    t.string "role"
    t.date "start_date"
    t.string "tech_stack"
    t.datetime "updated_at", null: false
    t.integer "work_experience_id", null: false
    t.index ["work_experience_id"], name: "index_client_projects_on_work_experience_id"
  end

  create_table "client_reviews", force: :cascade do |t|
    t.string "client_name"
    t.string "client_position"
    t.integer "client_project_id", null: false
    t.datetime "created_at", null: false
    t.integer "rating"
    t.text "review_text"
    t.datetime "updated_at", null: false
    t.index ["client_project_id"], name: "index_client_reviews_on_client_project_id"
  end

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "employee_count_range"
    t.integer "founded_year"
    t.string "industry"
    t.string "location"
    t.string "logo_url"
    t.string "name"
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false, null: false
    t.string "website"
    t.index ["name", "location", "website"], name: "index_companies_on_name_location_website", unique: true
  end

  create_table "education", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "degree"
    t.text "description"
    t.integer "end_year"
    t.text "field_of_study"
    t.text "grade"
    t.text "institution"
    t.integer "start_year"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_education_on_user_id"
  end

  create_table "experience_skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "notes"
    t.string "proficiency_level"
    t.integer "skill_id", null: false
    t.datetime "updated_at", null: false
    t.integer "work_experience_id", null: false
    t.float "years_of_experience"
    t.index ["skill_id"], name: "index_experience_skills_on_skill_id"
    t.index ["work_experience_id"], name: "index_experience_skills_on_work_experience_id"
  end

  create_table "skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_skills_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false
    t.string "availability_status", default: "available"
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "full_name"
    t.string "headline"
    t.string "hourly_rate"
    t.string "location"
    t.string "phone"
    t.text "portfolio_settings"
    t.integer "profile_completeness", default: 0
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.text "seo_description"
    t.string "seo_title"
    t.text "social_links"
    t.string "tagline"
    t.string "timezone"
    t.datetime "updated_at", null: false
    t.integer "years_of_experience"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["full_name"], name: "index_users_on_full_name"
    t.index ["location"], name: "index_users_on_location"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "work_experiences", force: :cascade do |t|
    t.integer "company_id"
    t.text "company_text"
    t.datetime "created_at", null: false
    t.text "description"
    t.date "end_date"
    t.string "experience_letter"
    t.string "relieving_letter"
    t.date "start_date"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["company_id"], name: "index_work_experiences_on_company_id"
    t.index ["user_id"], name: "index_work_experiences_on_user_id"
  end

  add_foreign_key "certifications", "users"
  add_foreign_key "client_projects", "work_experiences"
  add_foreign_key "client_projects", "work_experiences"
  add_foreign_key "client_reviews", "client_projects"
  add_foreign_key "education", "users"
  add_foreign_key "experience_skills", "skills"
  add_foreign_key "experience_skills", "work_experiences"
  add_foreign_key "experience_skills", "work_experiences"
  add_foreign_key "work_experiences", "companies"
  add_foreign_key "work_experiences", "users"
end
