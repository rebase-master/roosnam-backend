class Skill < ApplicationRecord
  belongs_to :work_experience, optional: true

  validates :name, presence: true
  validates :years_of_experience,
            numericality: { greater_than_or_equal_to: 0, less_than: 100 },
            allow_nil: true
  validates :proficiency_level,
            inclusion: { in: %w[beginner intermediate advanced expert], allow_nil: true }

  before_validation :generate_slug, if: -> { name.present? && (slug.blank? || name_changed?) }

  private

  def generate_slug
    base_slug = name.parameterize
    candidate_slug = base_slug
    counter = 1

    # Ensure uniqueness by appending a number if needed
    while Skill.where(slug: candidate_slug).where.not(id: id).exists?
      candidate_slug = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = candidate_slug
  end
end
