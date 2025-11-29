class ClientProject < ApplicationRecord
  belongs_to :user
  has_many :client_reviews, dependent: :destroy
  has_and_belongs_to_many :skills
  has_many_attached :project_images

  has_many :client_reviews, dependent: :destroy

  validates :name, presence: true
  # Auto-assign to singleton user if not set
  before_validation :set_default_user, on: :create

  private

  def set_default_user
    self.user ||= User.first
  end
end
