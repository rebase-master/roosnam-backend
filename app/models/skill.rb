class Skill < ApplicationRecord
  has_many :experience_skills, dependent: :destroy
  has_many :work_experiences, through: :experience_skills

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
end


