class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  has_many :company_experiences, dependent: :nullify
  has_many :education, class_name: 'Education', dependent: :nullify
  has_many :certifications, dependent: :nullify
  has_many :attachments, as: :owner, dependent: :destroy

  # JSON serialization for TEXT columns (SQLite compatible)
  serialize :social_links, coder: JSON
  serialize :portfolio_settings, coder: JSON

  # Enforce single-user (singleton) pattern
  validate :enforce_singleton, on: :create
  before_validation :ensure_admin_flag, on: :create
  validate :prevent_admin_demotion, on: :update

  # Profile validations
  validates :full_name, presence: true, if: :profile_fields_present?
  validates :availability_status,
    inclusion: { in: %w[available open_to_opportunities not_available] },
    allow_nil: true

  # Callbacks
  before_save :calculate_profile_completeness
  after_initialize :set_default_json_fields

  # Current role/company from company_experiences table
  def current_experience
    company_experiences
      .where(end_date: nil)
      .order(start_date: :desc)
      .first
  end

  def current_role
    current_experience&.title
  end

  def current_company_name
    exp = current_experience
    return nil unless exp

    if exp.company
      exp.company.name
    else
      exp.company_text
    end
  end

  # Display name falls back to full_name
  def display_name
    super.presence || full_name
  end

  # Profile photo via attachments
  def profile_photo
    attachments.find_by(caption: 'profile_photo')
  end

  # Resume via attachments
  def resume
    attachments.find_by(caption: 'resume')
  end

  # Portfolio setting helpers
  def show_email?
    portfolio_settings.dig('show_email') != false  # default true
  end

  def show_phone?
    portfolio_settings.dig('show_phone') == true  # default false
  end

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

  def profile_fields_present?
    # Only validate full_name if any profile fields are being set
    headline.present? || bio.present? || location.present?
  end

  def set_default_json_fields
    self.social_links ||= {}
    self.portfolio_settings ||= {
      'show_email' => true,
      'show_phone' => false,
      'theme_preference' => 'light'
    }
  end

  def calculate_profile_completeness
    required_fields = %i[full_name email headline bio location]
    optional_fields = %i[phone tagline years_of_experience]

    required_filled = required_fields.count { |f| send(f).present? }
    optional_filled = optional_fields.count { |f| send(f).present? }

    # Required fields worth 70%, optional 30%
    required_score = (required_filled.to_f / required_fields.size) * 70
    optional_score = (optional_filled.to_f / optional_fields.size) * 30

    self.profile_completeness = (required_score + optional_score).round
  end
end


