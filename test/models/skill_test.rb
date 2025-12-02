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

  # Association Tests
  test "should belong to work_experience optionally" do
    assert_respond_to @skill, :work_experience
  end

  test "should have many project_skills" do
    assert_respond_to @skill, :project_skills
  end

  test "should have many client_projects through project_skills" do
    assert_respond_to @skill, :client_projects
  end

  test "should be associated with client projects via project_skills" do
    project = client_projects(:ecommerce_project)
    ProjectSkill.create!(client_project: project, skill: @skill)
    assert_includes @skill.client_projects, project
  end

  test "should destroy project_skills when skill is destroyed" do
    project = client_projects(:ecommerce_project)
    project_skill = ProjectSkill.create!(client_project: project, skill: @skill)
    @skill.destroy
    assert_not ProjectSkill.exists?(id: project_skill.id)
  end

  # Slug Generation Edge Cases
  test "should handle special characters in name for slug" do
    skill = Skill.create(name: "C++ & Python")
    # parameterize removes special chars, so & becomes empty
    assert_equal "c-python", skill.slug
  end

  test "should handle unicode characters in name" do
    skill = Skill.create(name: "Résumé Skills")
    assert skill.slug.present?
    assert_equal skill.slug, skill.slug.parameterize
  end

  test "should handle very long names" do
    long_name = "A" * 100
    skill = Skill.create(name: long_name)
    assert skill.slug.present?
    assert skill.slug.length <= 100
  end

  test "should not regenerate slug if name unchanged but other attributes change" do
    original_slug = @skill.slug
    @skill.proficiency_level = 'advanced'
    @skill.save
    assert_equal original_slug, @skill.slug
  end

  test "should regenerate slug when name changes" do
    original_slug = @skill.slug
    @skill.name = "New Skill Name"
    @skill.save
    assert_not_equal original_slug, @skill.slug
    assert_equal "new-skill-name", @skill.slug
  end

  test "should generate slug on create even if slug is blank" do
    skill = Skill.new(name: "Test Skill", slug: "")
    skill.valid?
    assert_equal "test-skill", skill.slug
  end

  test "should handle slug generation with existing slug" do
    skill1 = Skill.create!(name: "Test")
    skill2 = Skill.new(name: "Test")
    skill2.valid?
    assert_equal "test-1", skill2.slug
  end

  test "generate_slug should handle multiple duplicates correctly" do
    Skill.create!(name: "Popular")
    Skill.create!(name: "Popular")
    skill3 = Skill.new(name: "Popular")
    skill3.valid?
    assert_equal "popular-2", skill3.slug
  end

  test "generate_slug should handle while loop for uniqueness" do
    # Create multiple skills with same name to test the while loop
    Skill.create!(name: "Test")
    Skill.create!(name: "Test")
    Skill.create!(name: "Test")
    skill4 = Skill.new(name: "Test")
    skill4.valid?
    assert_equal "test-3", skill4.slug
  end

  test "generate_slug should handle existing skill with same slug" do
    existing = Skill.create!(name: "Test Skill", slug: "test-skill")
    new_skill = Skill.new(name: "Test Skill")
    new_skill.valid?
    # Should append -1 since existing has slug "test-skill"
    assert_equal "test-skill-1", new_skill.slug
  end

  # Scope Tests
  test "for_portfolio_user scope should return skills from user's work experiences" do
    user = users(:portfolio_user)
    work_exp = work_experiences(:current_job)
    skill = skills(:ruby)
    skill.update(work_experience: work_exp)

    skills = Skill.for_portfolio_user(user.id)
    assert_includes skills.map(&:id), skill.id
  end

  test "for_portfolio_user scope should return skills from user's client projects" do
    user = users(:portfolio_user)
    project = client_projects(:ecommerce_project)
    skill = skills(:ruby)
    ProjectSkill.create!(client_project: project, skill: skill)

    skills = Skill.for_portfolio_user(user.id)
    assert_includes skills.map(&:id), skill.id
  end

  test "for_portfolio_user scope should return distinct skills" do
    user = users(:portfolio_user)
    work_exp = work_experiences(:current_job)
    project = client_projects(:ecommerce_project)
    skill = skills(:ruby)
    
    skill.update(work_experience: work_exp)
    ProjectSkill.create!(client_project: project, skill: skill)

    skills = Skill.for_portfolio_user(user.id)
    skill_ids = skills.map(&:id)
    assert_equal 1, skill_ids.count(skill.id), "Skill should appear only once"
  end

  test "for_portfolio_user scope should order by years_of_experience desc then name" do
    user = users(:portfolio_user)
    work_exp = work_experiences(:current_job)
    skill1 = skills(:ruby)
    skill2 = skills(:javascript)
    
    skill1.update(years_of_experience: 5, work_experience: work_exp)
    skill2.update(years_of_experience: 10, work_experience: work_exp)

    skills = Skill.for_portfolio_user(user.id)
    skill_ids = skills.map(&:id)
    skill2_index = skill_ids.index(skill2.id)
    skill1_index = skill_ids.index(skill1.id)
    
    assert skill2_index < skill1_index, "Skill with more experience should come first"
  end
end
