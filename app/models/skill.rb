class Skill < ApplicationRecord
  belongs_to :work_experience, optional: true
  has_many :project_skills, dependent: :destroy
  has_many :client_projects, through: :project_skills

  validates :name, presence: true
  validates :years_of_experience,
            numericality: { greater_than_or_equal_to: 0, less_than: 100 },
            allow_nil: true
  validates :proficiency_level,
            inclusion: { in: %w[beginner intermediate advanced expert], allow_nil: true }

  before_validation :generate_slug, if: -> { name.present? && (slug.blank? || name_changed?) }

  # Scope to get all skills associated with a user's work experiences or client projects
  # Returns distinct skills with source_company from work experiences
  scope :for_portfolio_user, lambda { |user_id|
    left_joins(:work_experience)
      .joins(<<~SQL.squish)
        LEFT JOIN project_skills
          ON project_skills.skill_id = skills.id
        LEFT JOIN client_projects
          ON client_projects.id = project_skills.client_project_id
      SQL
      .where(<<~SQL.squish, user_id: user_id)
        work_experiences.user_id = :user_id
        OR client_projects.user_id = :user_id
      SQL
      .select('DISTINCT skills.*, work_experiences.employer_name AS source_company')
      .order(Arel.sql('skills.years_of_experience DESC NULLS LAST'), :name)
  }

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
