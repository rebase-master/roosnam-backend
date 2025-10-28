class ClientReview < ApplicationRecord
  belongs_to :client_project

  validates :client_name, presence: true
  validates :client_position, presence: true
  validates :review_text, presence: true
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true

  scope :with_rating, -> { where.not(rating: nil) }
end

