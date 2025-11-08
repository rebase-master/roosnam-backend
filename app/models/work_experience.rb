class WorkExperience < ApplicationRecord
  belongs_to :user
  belongs_to :company, optional: true

  has_many :experience_skills, dependent: :destroy
  has_many :skills, through: :experience_skills
  has_many :client_projects, dependent: :destroy
  has_many :attachments, as: :owner, dependent: :destroy

  validates :title, presence: true
  validates :start_date, presence: true

  # Auto-assign to singleton user if not set
  before_validation :set_default_user, on: :create

  # Custom label for RailsAdmin
  def custom_label
    "#{title} at #{company&.name || company_text || 'Unknown Company'}"
  end

  private

  def set_default_user
    self.user ||= User.first
  end
end

