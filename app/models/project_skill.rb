class ProjectSkill < ApplicationRecord
  belongs_to :client_project
  belongs_to :skill

  validates :client_project_id, uniqueness: { scope: :skill_id }
end
