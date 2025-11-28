class WorkExperience < ApplicationRecord
  belongs_to :user

  has_many :skills, dependent: :nullify

  validates :employer_name, presence: true
  validates :job_title, presence: true
  validates :start_date, presence: true
  validate :end_date_after_start_date

  before_validation :set_default_user, on: :create

  scope :current, -> { where(end_date: nil) }
  scope :past, -> { where.not(end_date: nil) }

  def current?
    end_date.nil?
  end

  def duration_in_months
    end_dt = end_date || Date.current
    ((end_dt.year * 12 + end_dt.month) - (start_date.year * 12 + start_date.month))
  end

  def custom_label
    "#{job_title} at #{employer_name}"
  end

  private

  def set_default_user
    self.user ||= User.first
  end

  def end_date_after_start_date
    return unless start_date.present? && end_date.present?
    errors.add(:end_date, "must be after start date") if end_date < start_date
  end
end
