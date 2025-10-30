class ClientReview < ApplicationRecord
  belongs_to :client_project

  validates :client_name, presence: true
  validates :review_text, presence: true
  validates :rating, numericality: { allow_nil: true, in: 1..5 }
end


