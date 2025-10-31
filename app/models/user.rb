class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  has_many :company_experiences, dependent: :nullify
  has_many :education, class_name: 'Education', dependent: :nullify
  has_many :certifications, dependent: :nullify
  has_many :attachments, as: :owner, dependent: :destroy

  # Enforce single-user (singleton) pattern
  validate :enforce_singleton, on: :create
  before_validation :ensure_admin_flag, on: :create
  validate :prevent_admin_demotion, on: :update

  private

  def enforce_singleton
    if User.exists?
      errors.add(:base, "Only one user is allowed in this application")
    end
  end

  def ensure_admin_flag
    self.admin = true
  end

  def prevent_admin_demotion
    if admin_changed? && !admin
      errors.add(:admin, "cannot be revoked for the portfolio owner")
    end
  end
end


