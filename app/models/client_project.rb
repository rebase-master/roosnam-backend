class ClientProject < ApplicationRecord
  belongs_to :user
  has_many :client_reviews, dependent: :destroy
  has_many :project_skills, dependent: :destroy
  has_many :skills, through: :project_skills
  has_many_attached :project_images

  validates :name, presence: true
  # Auto-assign to singleton user if not set
  before_validation :set_default_user, on: :create

  private

  def set_default_user
    self.user ||= User.first
  end
end
