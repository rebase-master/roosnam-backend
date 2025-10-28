class Skill < ApplicationRecord
  has_many :experience_skills, dependent: :destroy
  has_many :company_experiences, through: :experience_skills

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :proficiency_level, presence: true, inclusion: { in: %w[Beginner Intermediate Advanced] }
  validates :years_of_experience, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :generate_slug, on: :create

  scope :by_proficiency, ->(level) { where(proficiency_level: level) }

  private

  def generate_slug
    self.slug ||= name.parameterize if name.present?
  end
end

