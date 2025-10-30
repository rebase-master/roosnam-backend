class CreateAttachments < ActiveRecord::Migration[8.1]
  def change
    create_table :attachments do |t|
      t.text :owner_type, null: false
      t.integer :owner_id, null: false
      t.string :url
      t.text :filename
      t.text :content_type
      t.bigint :size_bytes
      t.string :caption
      t.integer :position
      t.timestamps
    end

    add_index :attachments, [:owner_type, :owner_id]
  end
end


