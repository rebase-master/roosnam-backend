class WorkExperience < ApplicationRecord
  belongs_to :user
  belongs_to :company, optional: true

  has_many :skills
  has_many :client_projects, dependent: :destroy

  validates :job_title, presence: true
  validates :start_date, presence: true

  # Auto-assign to singleton user if not set
  before_validation :set_default_user, on: :create

  # Custom label for RailsAdmin
  def custom_label
    "#{job_title} at #{employer_name || 'Unknown Company'}"
  end

  private

  def set_default_user
    self.user ||= User.first
  end
end

