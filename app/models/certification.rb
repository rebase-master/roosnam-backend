class Certification < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :issuer, presence: true
  has_one_attached :document

  # Auto-assign to singleton user if not set
  before_validation :set_default_user, on: :create

  private

  def set_default_user
    self.user ||= User.first
  end
end


