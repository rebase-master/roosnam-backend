class Certification < ApplicationRecord
  belongs_to :user
  has_many :attachments, as: :owner, dependent: :destroy

  validates :title, presence: true
  validates :issuer, presence: true

  # Auto-assign to singleton user if not set
  before_validation :set_default_user, on: :create

  private

  def set_default_user
    self.user ||= User.first
  end
end


