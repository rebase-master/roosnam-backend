class CompanyExperience < ApplicationRecord
  belongs_to :user
  belongs_to :company, optional: true

  has_many :experience_skills, dependent: :destroy
  has_many :skills, through: :experience_skills
  has_many :client_projects, dependent: :destroy
  has_many :attachments, as: :owner, dependent: :destroy

  validates :title, presence: true
  validates :start_date, presence: true
end


