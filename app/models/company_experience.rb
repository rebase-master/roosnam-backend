class CompanyExperience < ApplicationRecord
  belongs_to :company
  has_many :experience_skills, dependent: :destroy
  has_many :skills, through: :experience_skills
  has_many :client_projects, dependent: :destroy

  validates :title, presence: true
  validates :joining_date, presence: true
  validates :leaving_date, comparison: { greater_than_or_equal_to: :joining_date }, allow_nil: true

  scope :current, -> { where(leaving_date: nil) }
  scope :past, -> { where.not(leaving_date: nil) }
end

