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

ActiveRecord::Schema[8.1].define(version: 2025_11_08_130819) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "attachments", force: :cascade do |t|
    t.integer "attachable_id", null: false
    t.string "attachable_type", null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.string "file_name", null: false
    t.string "file_type"
    t.string "file_url", null: false
    t.datetime "updated_at", null: false
    t.index ["attachable_type", "attachable_id"], name: "index_attachments_on_attachable"
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
    t.string "client_name"
    t.string "client_website"
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.date "end_date"
    t.string "name", null: false
    t.string "project_url"
    t.string "role"
    t.date "start_date"
    t.string "tech_stack"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_client_projects_on_user_id"
  end

  create_table "client_reviews", force: :cascade do |t|
    t.integer "client_project_id", null: false
    t.datetime "created_at", null: false
    t.integer "rating", limit: 1
    t.text "review_text", null: false
    t.string "reviewer_company"
    t.string "reviewer_name"
    t.string "reviewer_position"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["client_project_id"], name: "index_client_reviews_on_client_project_id"
    t.index ["user_id"], name: "index_client_reviews_on_user_id"
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

  create_table "skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "proficiency_level"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.integer "work_experience_id"
    t.decimal "years_of_experience", precision: 3, scale: 1
    t.index ["slug"], name: "index_skills_on_slug", unique: true
    t.index ["work_experience_id"], name: "index_skills_on_work_experience_id"
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
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "employer_name", null: false
    t.date "end_date"
    t.string "job_title"
    t.date "start_date"
    t.string "state"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_work_experiences_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "certifications", "users"
  add_foreign_key "client_projects", "users"
  add_foreign_key "client_reviews", "client_projects"
  add_foreign_key "client_reviews", "users"
  add_foreign_key "education", "users"
  add_foreign_key "skills", "work_experiences"
  add_foreign_key "work_experiences", "users"
end
