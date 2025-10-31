class Education < ApplicationRecord
  self.table_name = 'education'

  belongs_to :user

  validates :institution, presence: true
  validates :degree, presence: true

  # Auto-assign to singleton user if not set
  before_validation :set_default_user, on: :create

  private

  def set_default_user
    self.user ||= User.first
  end
end


