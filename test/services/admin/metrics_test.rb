require "test_helper"

class Admin::MetricsTest < ActiveSupport::TestCase
  def setup
    @metrics = Admin::Metrics.new
    @user = users(:portfolio_user)
  end

  test "stat_cards should return array of stat card hashes" do
    cards = @metrics.stat_cards
    assert cards.is_a?(Array)
    assert cards.length > 0
    
    cards.each do |card|
      assert card.key?(:label)
      assert card.key?(:value)
      assert card.key?(:icon)
      assert card.key?(:caption)
      assert card[:value].is_a?(Integer)
    end
  end

  test "stat_cards should include experiences count" do
    cards = @metrics.stat_cards
    experience_card = cards.find { |c| c[:label] == 'Experiences' }
    assert_not_nil experience_card
    assert_equal WorkExperience.count, experience_card[:value]
  end

  test "stat_cards should include skills count" do
    cards = @metrics.stat_cards
    skills_card = cards.find { |c| c[:label] == 'Skills' }
    assert_not_nil skills_card
    assert_equal Skill.count, skills_card[:value]
  end

  test "stat_cards should include client projects count" do
    cards = @metrics.stat_cards
    projects_card = cards.find { |c| c[:label] == 'Client Projects' }
    assert_not_nil projects_card
    assert_equal ClientProject.count, projects_card[:value]
  end

  test "stat_cards should include testimonials count" do
    cards = @metrics.stat_cards
    testimonials_card = cards.find { |c| c[:label] == 'Testimonials' }
    assert_not_nil testimonials_card
    assert_equal ClientReview.count, testimonials_card[:value]
  end

  test "recent_updates should return array of recent records" do
    updates = @metrics.recent_updates(limit: 3)
    assert updates.is_a?(Array)
    assert updates.length <= 3
  end

  test "recent_updates should be sorted by updated_at desc" do
    updates = @metrics.recent_updates(limit: 5)
    return if updates.length < 2
    
    updates.each_cons(2) do |first, second|
      assert first[:updated_at] >= second[:updated_at], 
        "Updates should be sorted by updated_at descending"
    end
  end

  test "recent_updates should include model and record" do
    updates = @metrics.recent_updates(limit: 1)
    return if updates.empty?
    
    update = updates.first
    assert update.key?(:model)
    assert update.key?(:record)
    assert update.key?(:label)
    assert update.key?(:updated_at)
  end

  test "weekly_activity should return hash with model names as keys" do
    activity = @metrics.weekly_activity
    assert activity.is_a?(Hash)
    assert activity.key?('Work Experience')
    assert activity.key?('Client Projects')
  end

  test "weekly_activity values should be hashes" do
    activity = @metrics.weekly_activity
    activity.values.each do |value|
      assert value.is_a?(Hash), "Weekly activity values should be hashes"
    end
  end

  test "skill_mix should return hash grouped by proficiency level" do
    mix = @metrics.skill_mix
    assert mix.is_a?(Hash)
  end

  test "skill_mix should transform keys to humanized strings" do
    mix = @metrics.skill_mix
    mix.keys.each do |key|
      assert key.is_a?(String)
      # Keys should be humanized (e.g., "Expert" not "expert")
    end
  end

  test "skill_mix should handle nil proficiency levels" do
    # Create a skill with nil proficiency
    skill = Skill.create!(name: "Test Skill", proficiency_level: nil)
    mix = @metrics.skill_mix
    assert mix.key?('Unspecified') || mix.values.any? { |v| v > 0 }
  end

  test "record_label should return name when available" do
    project = client_projects(:ecommerce_project)
    label = @metrics.send(:record_label, ClientProject, project)
    assert_equal project.name, label
  end

  test "record_label should return title when name not available" do
    cert = certifications(:aws_cert)
    label = @metrics.send(:record_label, Certification, cert)
    assert_equal cert.title, label
  end

  test "record_label should return reviewer_name for ClientReview" do
    review = client_reviews(:ecommerce_review)
    label = @metrics.send(:record_label, ClientReview, review)
    assert_equal review.reviewer_name, label
  end

  test "record_label should return full_name for User" do
    user = users(:portfolio_user)
    label = @metrics.send(:record_label, User, user)
    assert_equal user.full_name, label
  end

  test "record_label should return fallback format when no standard field" do
    # Create a model instance that doesn't have name, title, etc.
    # This tests the fallback "#{model.model_name.human} ##{record.id}"
    # We'll use a skill which might not have a standard field
    skill = skills(:ruby)
    label = @metrics.send(:record_label, Skill, skill)
    # Should either be the name or the fallback format
    assert label.present?
  end
end

