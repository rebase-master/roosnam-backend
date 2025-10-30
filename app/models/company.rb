class Company < ApplicationRecord
  has_many :company_experiences, dependent: :nullify

  validates :name, presence: true
end


