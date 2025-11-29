require "test_helper"

class SkillTest < ActiveSupport::TestCase
  def setup
    @skill = skills(:ruby)
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    assert @skill.valid?
  end

  test "should require name" do
    @skill.name = nil
    assert_not @skill.valid?
    assert_includes @skill.errors[:name], "can't be blank"
  end

  test "should validate years_of_experience is non-negative" do
    @skill.years_of_experience = -1
    assert_not @skill.valid?
    assert_includes @skill.errors[:years_of_experience], "must be greater than or equal to 0"
  end

  test "should validate years_of_experience is less than 100" do
    @skill.years_of_experience = 100
    assert_not @skill.valid?
    assert_includes @skill.errors[:years_of_experience], "must be less than 100"
  end

  test "should allow nil years_of_experience" do
    @skill.years_of_experience = nil
    assert @skill.valid?
  end

  test "should validate proficiency_level inclusion" do
    @skill.proficiency_level = "invalid"
    assert_not @skill.valid?
    assert_includes @skill.errors[:proficiency_level], "is not included in the list"
  end

  test "should accept valid proficiency levels" do
    %w[beginner intermediate advanced expert].each do |level|
      @skill.proficiency_level = level
      assert @skill.valid?, "#{level} should be valid"
    end
  end

  test "should allow nil proficiency_level" do
    @skill.proficiency_level = nil
    assert @skill.valid?
  end

  # Slug Generation Tests
  test "should generate slug from name on create" do
    skill = Skill.create(name: "Test Skill")
    assert_equal "test-skill", skill.slug
  end

  test "should update slug when name changes" do
    @skill.name = "New Skill Name"
    @skill.save
    assert_equal "new-skill-name", @skill.slug
  end

  test "should ensure slug uniqueness" do
    skill1 = Skill.create(name: "Unique Skill")
    skill2 = Skill.create(name: "Unique Skill")

    assert_equal "unique-skill", skill1.slug
    assert_equal "unique-skill-1", skill2.slug
  end

  test "should handle slug uniqueness with multiple duplicates" do
    Skill.create(name: "Popular")
    Skill.create(name: "Popular")
    skill3 = Skill.create(name: "Popular")

    assert_equal "popular-2", skill3.slug
  end

  test "should not change slug if name hasn't changed" do
    original_slug = @skill.slug
    @skill.years_of_experience = 10
    @skill.save
    assert_equal original_slug, @skill.slug
  end
end
