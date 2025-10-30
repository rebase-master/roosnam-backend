class Education < ApplicationRecord
  self.table_name = 'education'

  belongs_to :user

  validates :institution, presence: true
  validates :degree, presence: true
end


