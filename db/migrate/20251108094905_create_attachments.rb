class CreateAttachments < ActiveRecord::Migration[8.1]
  def change
    create_table :attachments do |t|
      t.string :file_name, null: false
      t.string :file_type # MIME type, e.g., image/png, application/pdf
      t.string :file_url, null: false
      t.string :category # optional: e.g., "profile_photo", "project_image"
      t.references :attachable, polymorphic: true, null: false, index: true
      t.timestamps
    end
  end
end
