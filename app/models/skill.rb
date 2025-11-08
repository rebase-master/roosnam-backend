class Skill < ApplicationRecord
  belongs_to :user
  validates :name, presence: true
  validates :years_of_experience,
            numericality: { greater_than_or_equal_to: 0, less_than: 100 },
            allow_nil: true
  validates :proficiency_level,
            inclusion: { in: %w[beginner intermediate advanced expert], allow_nil: true }
end
