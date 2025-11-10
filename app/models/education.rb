class Education < ApplicationRecord
  self.table_name = 'education'

  belongs_to :user
  has_one_attached :certificate

  enum :degree_status, {
    graduated: 'graduated',
    incomplete: 'incomplete',
    now_attending: 'now_attending'
  }

  validates :school_name, presence: true
  validates :degree, presence: true
  validates :degree_status, presence: true
  validates :field_of_study, presence: true
  validates :start_year, presence: true, numericality: { only_integer: true, greater_than: 1900, less_than_or_equal_to: 2100 }
  validates :end_year, presence: true, numericality: { only_integer: true, greater_than: 1900, less_than_or_equal_to: 2100 }
  validate :end_year_after_start_year

  # Method for rails_admin enum dropdown
  def self.degree_status_enum
    degree_statuses.to_a.map { |key, value| [key.titleize, value] }
  end

  # Auto-assign to singleton user if not set
  before_validation :set_default_user, on: :create
  before_validation :set_default_degree_status, if: -> { degree_status.blank? }

  private

  def set_default_user
    self.user ||= User.first
  end

  def set_default_degree_status
    self.degree_status = 'now_attending' if degree_status.blank?
  end

  def end_year_after_start_year
    return unless start_year.present? && end_year.present?

    errors.add(:end_year, 'must be greater than or equal to start year') if end_year < start_year
  end
end


