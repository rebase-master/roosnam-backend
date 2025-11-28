class ClientProject < ApplicationRecord
  belongs_to :user

  has_many :client_reviews, dependent: :destroy

  has_many :project_skills, dependent: :destroy
  has_many :skills, through: :project_skills

  has_many_attached :project_images

  validates :name, presence: true
  validates :description, presence: true

  before_validation :set_default_user, on: :create

  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(end_date: :desc, start_date: :desc) }

  def tech_stack_array
    tech_stack&.split(',')&.map(&:strip) || []
  end

  private

  def set_default_user
    self.user ||= User.first
  end
end
