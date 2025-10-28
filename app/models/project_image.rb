class ProjectImage < ApplicationRecord
  belongs_to :client_project

  validates :image_url, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:position) }
end

