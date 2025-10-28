class Company < ApplicationRecord
  has_many :company_experiences, dependent: :destroy

  validates :name, presence: true
  validates :location, presence: true
end

