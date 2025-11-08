class Company < ApplicationRecord
  has_many :work_experiences, dependent: :nullify

  validates :name, presence: true
end


