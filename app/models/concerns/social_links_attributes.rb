module SocialLinksAttributes
  extend ActiveSupport::Concern

  included do
    before_save :sync_social_links_to_json
    before_save :sync_portfolio_settings_to_json
  end

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

  private

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
end


