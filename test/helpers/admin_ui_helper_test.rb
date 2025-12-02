require "test_helper"

class AdminUiHelperTest < ActionView::TestCase
  include AdminUiHelper

  test "admin_model_icon should return icon for known models" do
    assert_equal 'fa-user-circle', admin_model_icon('User')
    assert_equal 'fa-briefcase', admin_model_icon('WorkExperience')
    assert_equal 'fa-graduation-cap', admin_model_icon('Education')
    assert_equal 'fa-lightbulb', admin_model_icon('Skill')
    assert_equal 'fa-award', admin_model_icon('Certification')
    assert_equal 'fa-diagram-project', admin_model_icon('ClientProject')
    assert_equal 'fa-comments', admin_model_icon('ClientReview')
  end

  test "admin_model_icon should return default icon for unknown models" do
    assert_equal 'fa-folder-tree', admin_model_icon('UnknownModel')
  end

  test "availability_badge should return badge for available status" do
    badge = availability_badge('available')
    assert badge.include?('Available') # humanize converts to "Available"
    assert badge.include?('badge-primary')
  end

  test "availability_badge should return badge for open_to_opportunities status" do
    badge = availability_badge('open_to_opportunities')
    assert badge.include?('Open to opportunities') # humanize converts to "Open to opportunities"
    assert badge.include?('badge-accent')
  end

  test "availability_badge should return badge for not_available status" do
    badge = availability_badge('not_available')
    assert badge.include?('Not available') # humanize converts to "Not available"
    assert badge.include?('badge-muted')
  end

  test "availability_badge should return empty string for blank value" do
    assert_equal '', availability_badge(nil)
    assert_equal '', availability_badge('')
  end

  test "rating_badge should return badge with star for rating" do
    badge = rating_badge(5)
    assert badge.include?('5')
    assert badge.include?('★')
  end

  test "rating_badge should return primary badge for rating >= 4" do
    badge = rating_badge(4)
    assert badge.include?('badge-primary')
  end

  test "rating_badge should return accent badge for rating < 4" do
    badge = rating_badge(3)
    assert badge.include?('badge-accent')
  end

  test "rating_badge should return empty string for blank value" do
    assert_equal '', rating_badge(nil)
    assert_equal '', rating_badge('')
  end

  test "status_badge should return badge with label and tone" do
    badge = status_badge('Test Label', :primary)
    assert badge.include?('Test Label')
    assert badge.include?('badge-primary')
  end

  test "status_badge should handle different tones" do
    assert status_badge('Test', :primary).include?('badge-primary')
    assert status_badge('Test', :accent).include?('badge-accent')
    assert status_badge('Test', :muted).include?('badge-muted')
    assert status_badge('Test', :unknown).include?('badge-muted')
  end
end

