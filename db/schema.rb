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

ActiveRecord::Schema[8.1].define(version: 2025_10_27_161938) do
  create_table "client_projects", force: :cascade do |t|
    t.integer "company_experience_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.date "end_date"
    t.string "name"
    t.string "project_url"
    t.string "role"
    t.date "start_date"
    t.string "tech_stack"
    t.datetime "updated_at", null: false
    t.index ["company_experience_id"], name: "index_client_projects_on_company_experience_id"
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
    t.integer "employee_count"
    t.string "industry"
    t.string "location"
    t.string "logo_url"
    t.string "name"
    t.datetime "updated_at", null: false
    t.string "website"
  end

  create_table "company_experiences", force: :cascade do |t|
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "experience_letter"
    t.date "joining_date"
    t.date "leaving_date"
    t.string "relieving_letter"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_experiences_on_company_id"
  end

  create_table "experience_skills", force: :cascade do |t|
    t.integer "company_experience_id", null: false
    t.datetime "created_at", null: false
    t.text "notes"
    t.integer "skill_id", null: false
    t.datetime "updated_at", null: false
    t.index ["company_experience_id"], name: "index_experience_skills_on_company_experience_id"
    t.index ["skill_id"], name: "index_experience_skills_on_skill_id"
  end

  create_table "project_images", force: :cascade do |t|
    t.string "caption"
    t.integer "client_project_id", null: false
    t.datetime "created_at", null: false
    t.string "image_url"
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["client_project_id"], name: "index_project_images_on_client_project_id"
  end

  create_table "skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "proficiency_level"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.float "years_of_experience"
    t.index ["slug"], name: "index_skills_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "client_projects", "company_experiences"
  add_foreign_key "client_reviews", "client_projects"
  add_foreign_key "company_experiences", "companies"
  add_foreign_key "experience_skills", "company_experiences"
  add_foreign_key "experience_skills", "skills"
  add_foreign_key "project_images", "client_projects"
end
