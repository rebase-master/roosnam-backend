class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable
  include SocialLinksAttributes

  attr_accessor :remove_resume

  has_many :work_experiences, dependent: :destroy
  has_many :education, class_name: 'Education', dependent: :destroy
  has_many :certifications, dependent: :destroy
  has_one_attached :profile_photo
  has_one_attached :resume

  has_many :client_projects, dependent: :destroy
  has_many :client_reviews, dependent: :destroy
  # JSON serialization for TEXT columns (SQLite compatible)
  serialize :social_links, coder: JSON
  serialize :portfolio_settings, coder: JSON

  validate :enforce_singleton, on: :create
  before_validation :ensure_admin_flag, on: :create
  validate :prevent_admin_demotion, on: :update

  validates :full_name, presence: true, if: :profile_fields_present?
  validates :full_name, length: { maximum: 60, message: "must be 60 characters or less" }, allow_nil: true
  validates :display_name, length: { maximum: 60, message: "must be 60 characters or less" }, allow_nil: true
  validates :availability_status,
            inclusion: { in: %w[available open_to_opportunities not_available] },
            allow_nil: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :resume,
            content_type: {
              in: ['application/pdf', 'application/msword'],
              message: 'must be a PDF or DOC file'
            },
            allow_nil: true

  before_save :purge_resume_if_requested
  before_save :calculate_profile_completeness
  after_initialize :set_default_json_fields
  after_commit :ensure_resume_filename, if: -> { resume.attached? }

  # Current role/company from work_experiences table
  def current_experience
    work_experiences
      .where(end_date: nil)
      .order(start_date: :desc)
      .first
  end

  def current_role
    current_experience&.job_title  # Changed from .title
  end

  def current_company_name
    exp = current_experience
    return nil unless exp

    # Company association doesn't exist, just use employer_name
    exp.employer_name
  end

  def display_name
    super.presence || full_name
  end

  # Portfolio setting helpers
  def show_email?
    portfolio_settings&.dig('show_email') != false
  end

  def show_phone?
    portfolio_settings&.dig('show_phone') == true
  end

  def total_experience_years
    work_experiences.sum(&:duration_in_months) / 12.0
  end

  private

  def purge_resume_if_requested
    return unless ActiveModel::Type::Boolean.new.cast(remove_resume)
    resume.purge if resume.attached?
  end

  def ensure_resume_filename
    return unless resume.attached?

    desired = generated_resume_filename
    current = resume.filename.to_s
    return if desired.blank? || desired == current

    # Update the blob's filename; this does not change the key/path
    resume.blob.update(filename: desired)
  end

  def generated_resume_filename
    date_str = Date.current.strftime('%d%m%Y')

    first_name, last_name = extract_first_and_last_name
    name_parts = []
    name_parts << first_name if first_name.present?
    name_parts << last_name if last_name.present?

    base =
      if name_parts.empty?
        date_str
      else
        "#{name_parts.join('_')}_#{date_str}"
      end

    # Sanitize: keep letters, numbers and underscores, collapse others to underscores
    sanitized_base = base.strip.gsub(/[^A-Za-z0-9]+/, '_').gsub(/^_+|_+$/, '').downcase

    ext = File.extname(resume.filename.to_s)
    ext = '.pdf' if ext.blank?

    "#{sanitized_base}#{ext}"
  end

  def extract_first_and_last_name
    return [nil, nil] if full_name.blank?

    parts = full_name.strip.split(/\s+/)
    first = parts.first
    last = parts[1..]&.join(' ')
    [first, last.presence]
  end

  def enforce_singleton
    errors.add(:base, "Only one user is allowed in this application") if User.exists?
  end

  def ensure_admin_flag
    self.admin = true
  end

  def prevent_admin_demotion
    errors.add(:admin, "cannot be revoked for the portfolio owner") if admin_changed? && !admin
  end

  def profile_fields_present?
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

    required_score = (required_filled.to_f / required_fields.size) * 70
    optional_score = (optional_filled.to_f / optional_fields.size) * 30

    self.profile_completeness = (required_score + optional_score).round
  end
end
