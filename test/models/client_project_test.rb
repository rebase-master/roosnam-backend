require "test_helper"

class ClientProjectTest < ActiveSupport::TestCase
  def setup
    @project = client_projects(:ecommerce_project)
    @user = users(:portfolio_user)
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    assert @project.valid?
  end

  test "should require name" do
    @project.name = nil
    assert_not @project.valid?
    assert_includes @project.errors[:name], "can't be blank"
  end

  # Association Tests
  test "should belong to user" do
    assert_respond_to @project, :user
    assert_equal @user, @project.user
  end

  test "should have many client_reviews" do
    assert_respond_to @project, :client_reviews
    assert_equal 1, @project.client_reviews.count
  end

  test "should have many skills through project_skills" do
    assert_respond_to @project, :skills
    assert_respond_to @project, :project_skills
  end

  test "should have many project_skills" do
    assert_respond_to @project, :project_skills
  end

  test "should add skills through project_skills association" do
    skill = skills(:ruby)
    @project.skills << skill
    assert_includes @project.skills, skill
    assert ProjectSkill.exists?(client_project: @project, skill: skill)
  end

  test "should destroy project_skills when project is destroyed" do
    skill = skills(:ruby)
    project_skill = ProjectSkill.create!(client_project: @project, skill: skill)
    @project.destroy
    assert_not ProjectSkill.exists?(id: project_skill.id)
  end

  test "should destroy dependent client_reviews when destroyed" do
    review_count_before = ClientReview.count
    @project.destroy
    assert_equal review_count_before - 1, ClientReview.count
  end

  # Auto-assign Tests
  test "should auto-assign to first user on create when user not set" do
    project = ClientProject.new(
      name: "Test Project",
      description: "Test Description"
    )
    project.save
    assert_equal User.first, project.user
  end

  test "should not override user if already set" do
    project = ClientProject.create(
      name: "Test Project",
      description: "Test Description",
      user: @user
    )
    assert_equal @user, project.user
  end

  # Skills Association Edge Cases
  test "should handle multiple skills on project" do
    skill1 = skills(:ruby)
    skill2 = skills(:javascript)
    @project.skills << [skill1, skill2]
    assert_equal 2, @project.skills.count
  end

  test "should handle removing skills from project" do
    skill = skills(:ruby)
    @project.skills << skill
    assert_includes @project.skills, skill
    @project.skills.delete(skill)
    assert_not_includes @project.skills, skill
  end

  test "should handle project with no skills" do
    @project.skills.clear
    assert_equal 0, @project.skills.count
  end

  # Project Images Tests
  test "should have many attached project_images" do
    assert_respond_to @project, :project_images
  end

  # Edge Cases
  test "set_default_user should not override existing user" do
    project = ClientProject.new(name: "Test", user: @user)
    project.valid?
    assert_equal @user, project.user
  end

  test "set_default_user should set user when nil" do
    project = ClientProject.new(name: "Test", user: nil)
    project.valid?
    assert_equal User.first, project.user
  end
end
