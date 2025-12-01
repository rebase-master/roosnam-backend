class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  # Sync virtual attributes to JSON columns before save
  before_save :sync_social_links_to_json
  before_save :sync_portfolio_settings_to_json

  # Virtual attribute accessors that read from JSON columns
  def linkedin_url
    @linkedin_url_set ? @linkedin_url : social_links&.dig('linkedin')
  end

  def linkedin_url=(val)
    @linkedin_url_set = true
    @linkedin_url = val
  end

  def github_url
    @github_url_set ? @github_url : social_links&.dig('github')
  end

  def github_url=(val)
    @github_url_set = true
    @github_url = val
  end

  def twitter_url
    @twitter_url_set ? @twitter_url : social_links&.dig('twitter')
  end

  def twitter_url=(val)
    @twitter_url_set = true
    @twitter_url = val
  end

  def website_url
    @website_url_set ? @website_url : social_links&.dig('website')
  end

  def website_url=(val)
    @website_url_set = true
    @website_url = val
  end

  def setting_show_email
    @setting_show_email_set ? @setting_show_email : portfolio_settings&.dig('show_email')
  end

  def setting_show_email=(val)
    @setting_show_email_set = true
    @setting_show_email = ActiveModel::Type::Boolean.new.cast(val)
  end

  def setting_show_phone
    @setting_show_phone_set ? @setting_show_phone : portfolio_settings&.dig('show_phone')
  end

  def setting_show_phone=(val)
    @setting_show_phone_set = true
    @setting_show_phone = ActiveModel::Type::Boolean.new.cast(val)
  end

  def setting_theme_preference
    @setting_theme_preference_set ? @setting_theme_preference : portfolio_settings&.dig('theme_preference')
  end

  def setting_theme_preference=(val)
    @setting_theme_preference_set = true
    @setting_theme_preference = val
  end

  has_many :work_experiences, dependent: :nullify
  has_many :education, class_name: 'Education', dependent: :nullify
  has_many :certifications, dependent: :nullify
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

  before_save :calculate_profile_completeness
  after_initialize :set_default_json_fields

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

  def sync_social_links_to_json
    # Only sync if any of the virtual attributes were explicitly set
    return unless @linkedin_url_set || @github_url_set || @twitter_url_set || @website_url_set

    self.social_links ||= {}
    new_links = {}
    new_links['linkedin'] = @linkedin_url.presence if @linkedin_url_set
    new_links['github'] = @github_url.presence if @github_url_set
    new_links['twitter'] = @twitter_url.presence if @twitter_url_set
    new_links['website'] = @website_url.presence if @website_url_set
    self.social_links = social_links.merge(new_links)
  end

  def sync_portfolio_settings_to_json
    # Only sync if any of the virtual attributes were explicitly set
    return unless @setting_show_email_set || @setting_show_phone_set || @setting_theme_preference_set

    self.portfolio_settings ||= {}
    new_settings = {}
    new_settings['show_email'] = @setting_show_email if @setting_show_email_set
    new_settings['show_phone'] = @setting_show_phone if @setting_show_phone_set
    new_settings['theme_preference'] = @setting_theme_preference if @setting_theme_preference_set && @setting_theme_preference.present?
    self.portfolio_settings = portfolio_settings.merge(new_settings)
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
