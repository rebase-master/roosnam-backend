class WorkExperience < ApplicationRecord
  belongs_to :user

  has_many :skills, dependent: :nullify
  # Note: client_projects relationship exists in code but work_experience_id column
  # doesn't exist in client_projects table, so commenting out to avoid errors
  # has_many :client_projects, dependent: :destroy

  validates :job_title, presence: true
  validates :start_date, presence: true

  # Auto-assign to singleton user if not set
  before_validation :set_default_user, on: :create

  # Custom label for RailsAdmin
  def custom_label
    "#{job_title} at #{employer_name || 'Unknown Company'}"
  end

  # Calculate duration in months for experience calculation
  def duration_in_months
    end_date_value = end_date || Date.current
    ((end_date_value.year * 12 + end_date_value.month) -
     (start_date.year * 12 + start_date.month))
  end

  private

  def set_default_user
    self.user ||= User.first
  end
end

