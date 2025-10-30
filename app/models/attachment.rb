class Attachment < ApplicationRecord
  belongs_to :owner, polymorphic: true

  validates :owner_type, presence: true
  validates :owner_id, presence: true
  validates :url, presence: true
end


