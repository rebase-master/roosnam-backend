class Attachment < ApplicationRecord
  belongs_to :attachable, polymorphic: true

  validates :file_url, presence: true
  validates :file_type, inclusion: {
    in: %w[image/png image/jpeg image/jpg image/webp application/pdf],
    message: "%{value} is not a supported format"
  }, allow_blank: true
end
