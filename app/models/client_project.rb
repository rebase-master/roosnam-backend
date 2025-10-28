class ClientProject < ApplicationRecord
  belongs_to :company_experience
  has_many :project_images, dependent: :destroy
  has_many :client_reviews, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :role, presence: true
  validates :end_date, comparison: { greater_than_or_equal_to: :start_date }, allow_nil: true

  scope :ordered, -> { order(created_at: :desc) }
end

