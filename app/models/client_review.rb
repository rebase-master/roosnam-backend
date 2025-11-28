class ClientReview < ApplicationRecord
  belongs_to :client_project
  belongs_to :user
  validates :reviewer_name, presence: true
  validates :review_text, presence: true
  validates :rating, numericality: { allow_nil: true, in: 1..5 }
end


