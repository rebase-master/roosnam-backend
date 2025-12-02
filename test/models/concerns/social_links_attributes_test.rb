require "test_helper"

class SocialLinksAttributesTest < ActiveSupport::TestCase
  def setup
    @user = users(:portfolio_user)
  end

  # LinkedIn URL Tests
  test "linkedin_url should read from social_links JSON when not set" do
    @user.social_links = { 'linkedin' => 'https://linkedin.com/in/test' }
    @user.save
    assert_equal 'https://linkedin.com/in/test', @user.linkedin_url
  end

  test "linkedin_url= should set the virtual attribute" do
    @user.linkedin_url = 'https://linkedin.com/in/new'
    assert_equal 'https://linkedin.com/in/new', @user.linkedin_url
  end

  test "linkedin_url= should sync to JSON on save" do
    @user.linkedin_url = 'https://linkedin.com/in/synced'
    @user.save
    assert_equal 'https://linkedin.com/in/synced', @user.social_links['linkedin']
  end

  # GitHub URL Tests
  test "github_url should read from social_links JSON when not set" do
    @user.social_links = { 'github' => 'https://github.com/test' }
    @user.save
    assert_equal 'https://github.com/test', @user.github_url
  end

  test "github_url= should set the virtual attribute" do
    @user.github_url = 'https://github.com/new'
    assert_equal 'https://github.com/new', @user.github_url
  end

  test "github_url= should sync to JSON on save" do
    @user.github_url = 'https://github.com/synced'
    @user.save
    assert_equal 'https://github.com/synced', @user.social_links['github']
  end

  # Twitter URL Tests
  test "twitter_url should read from social_links JSON when not set" do
    @user.social_links = { 'twitter' => 'https://twitter.com/test' }
    @user.save
    assert_equal 'https://twitter.com/test', @user.twitter_url
  end

  test "twitter_url= should set the virtual attribute" do
    @user.twitter_url = 'https://twitter.com/new'
    assert_equal 'https://twitter.com/new', @user.twitter_url
  end

  test "twitter_url= should sync to JSON on save" do
    @user.twitter_url = 'https://twitter.com/synced'
    @user.save
    assert_equal 'https://twitter.com/synced', @user.social_links['twitter']
  end

  # Website URL Tests
  test "website_url should read from social_links JSON when not set" do
    @user.social_links = { 'website' => 'https://example.com' }
    @user.save
    assert_equal 'https://example.com', @user.website_url
  end

  test "website_url= should set the virtual attribute" do
    @user.website_url = 'https://new-example.com'
    assert_equal 'https://new-example.com', @user.website_url
  end

  test "website_url= should sync to JSON on save" do
    @user.website_url = 'https://synced-example.com'
    @user.save
    assert_equal 'https://synced-example.com', @user.social_links['website']
  end

  # Portfolio Settings Tests
  test "setting_show_email should read from portfolio_settings JSON when not set" do
    @user.portfolio_settings = { 'show_email' => false }
    @user.save
    assert_equal false, @user.setting_show_email
  end

  test "setting_show_email= should set the virtual attribute" do
    @user.setting_show_email = true
    assert_equal true, @user.setting_show_email
  end

  test "setting_show_email= should sync to JSON on save" do
    @user.setting_show_email = false
    @user.save
    assert_equal false, @user.portfolio_settings['show_email']
  end

  test "setting_show_email= should cast string to boolean" do
    @user.setting_show_email = 'true'
    assert_equal true, @user.setting_show_email
    @user.setting_show_email = 'false'
    assert_equal false, @user.setting_show_email
  end

  test "setting_show_phone should read from portfolio_settings JSON when not set" do
    @user.portfolio_settings = { 'show_phone' => true }
    @user.save
    assert_equal true, @user.setting_show_phone
  end

  test "setting_show_phone= should set the virtual attribute" do
    @user.setting_show_phone = true
    assert_equal true, @user.setting_show_phone
  end

  test "setting_show_phone= should sync to JSON on save" do
    @user.setting_show_phone = true
    @user.save
    assert_equal true, @user.portfolio_settings['show_phone']
  end

  test "setting_theme_preference should read from portfolio_settings JSON when not set" do
    @user.portfolio_settings = { 'theme_preference' => 'dark' }
    @user.save
    assert_equal 'dark', @user.setting_theme_preference
  end

  test "setting_theme_preference= should set the virtual attribute" do
    @user.setting_theme_preference = 'dark'
    assert_equal 'dark', @user.setting_theme_preference
  end

  test "setting_theme_preference= should sync to JSON on save" do
    @user.setting_theme_preference = 'dark'
    @user.save
    assert_equal 'dark', @user.portfolio_settings['theme_preference']
  end

  test "setting_theme_preference= should not sync empty string" do
    @user.setting_theme_preference = ''
    @user.save
    # Empty string should not override existing value, so it keeps the default
    assert_equal 'light', @user.portfolio_settings['theme_preference']
  end

  # Sync Behavior Tests
  test "sync_social_links_to_json should only sync when attributes are set" do
    original_links = @user.social_links.dup
    @user.save
    assert_equal original_links, @user.social_links
  end

  test "sync_social_links_to_json should merge with existing links" do
    @user.social_links = { 'linkedin' => 'https://linkedin.com/existing' }
    @user.github_url = 'https://github.com/new'
    @user.save
    assert_equal 'https://linkedin.com/existing', @user.social_links['linkedin']
    assert_equal 'https://github.com/new', @user.social_links['github']
  end

  test "sync_portfolio_settings_to_json should only sync when attributes are set" do
    original_settings = @user.portfolio_settings.dup
    @user.save
    assert_equal original_settings, @user.portfolio_settings
  end

  test "sync_portfolio_settings_to_json should merge with existing settings" do
    @user.portfolio_settings = { 'show_email' => false, 'show_phone' => true }
    @user.setting_theme_preference = 'dark'
    @user.save
    assert_equal false, @user.portfolio_settings['show_email']
    assert_equal true, @user.portfolio_settings['show_phone']
    assert_equal 'dark', @user.portfolio_settings['theme_preference']
  end

  test "sync should handle nil values by removing from JSON" do
    @user.social_links = { 'linkedin' => 'https://linkedin.com/test' }
    @user.linkedin_url = nil
    @user.save
    assert_nil @user.social_links['linkedin']
  end

  test "sync_social_links_to_json should not sync when no attributes set" do
    original_links = @user.social_links.dup
    @user.save
    assert_equal original_links, @user.social_links
  end

  test "sync_portfolio_settings_to_json should not sync when no attributes set" do
    original_settings = @user.portfolio_settings.dup
    @user.save
    assert_equal original_settings, @user.portfolio_settings
  end

  test "sync should merge multiple social links" do
    @user.linkedin_url = 'https://linkedin.com/test'
    @user.github_url = 'https://github.com/test'
    @user.twitter_url = 'https://twitter.com/test'
    @user.website_url = 'https://example.com'
    @user.save
    assert_equal 'https://linkedin.com/test', @user.social_links['linkedin']
    assert_equal 'https://github.com/test', @user.social_links['github']
    assert_equal 'https://twitter.com/test', @user.social_links['twitter']
    assert_equal 'https://example.com', @user.social_links['website']
  end

  test "sync should merge multiple portfolio settings" do
    @user.setting_show_email = false
    @user.setting_show_phone = true
    @user.setting_theme_preference = 'dark'
    @user.save
    assert_equal false, @user.portfolio_settings['show_email']
    assert_equal true, @user.portfolio_settings['show_phone']
    assert_equal 'dark', @user.portfolio_settings['theme_preference']
  end

  test "sync_social_links_to_json should handle nil social_links" do
    @user.social_links = nil
    @user.linkedin_url = 'https://linkedin.com/test'
    @user.save
    assert_equal 'https://linkedin.com/test', @user.social_links['linkedin']
  end

  test "sync_portfolio_settings_to_json should handle nil portfolio_settings" do
    @user.portfolio_settings = nil
    @user.setting_show_email = false
    @user.save
    assert_equal false, @user.portfolio_settings['show_email']
  end

  test "sync should handle empty string values" do
    @user.linkedin_url = ''
    @user.save
    assert_nil @user.social_links['linkedin']
  end
end

