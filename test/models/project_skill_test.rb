require "test_helper"

class ProjectSkillTest < ActiveSupport::TestCase
  def setup
    @user = users(:portfolio_user)
    @project = client_projects(:ecommerce_project)
    @skill = skills(:ruby)
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    project_skill = ProjectSkill.new(
      client_project: @project,
      skill: @skill
    )
    assert project_skill.valid?
  end

  test "should require client_project" do
    project_skill = ProjectSkill.new(skill: @skill)
    assert_not project_skill.valid?
    assert_includes project_skill.errors[:client_project], "must exist"
  end

  test "should require skill" do
    project_skill = ProjectSkill.new(client_project: @project)
    assert_not project_skill.valid?
    assert_includes project_skill.errors[:skill], "must exist"
  end

  test "should validate uniqueness of client_project_id scoped to skill_id" do
    ProjectSkill.create!(client_project: @project, skill: @skill)
    duplicate = ProjectSkill.new(client_project: @project, skill: @skill)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:client_project_id], "has already been taken"
  end

  test "should allow same skill for different projects" do
    project1 = client_projects(:ecommerce_project)
    project2 = client_projects(:analytics_dashboard)
    skill = skills(:ruby)

    ProjectSkill.create!(client_project: project1, skill: skill)
    project_skill2 = ProjectSkill.new(client_project: project2, skill: skill)
    assert project_skill2.valid?
  end

  test "should allow different skills for same project" do
    project = client_projects(:ecommerce_project)
    skill1 = skills(:ruby)
    skill2 = skills(:javascript)

    ProjectSkill.create!(client_project: project, skill: skill1)
    project_skill2 = ProjectSkill.new(client_project: project, skill: skill2)
    assert project_skill2.valid?
  end

  # Association Tests
  test "should belong to client_project" do
    project_skill = ProjectSkill.create!(client_project: @project, skill: @skill)
    assert_respond_to project_skill, :client_project
    assert_equal @project, project_skill.client_project
  end

  test "should belong to skill" do
    project_skill = ProjectSkill.create!(client_project: @project, skill: @skill)
    assert_respond_to project_skill, :skill
    assert_equal @skill, project_skill.skill
  end

  # Integration Tests
  test "should be created when adding skill to project via association" do
    project = client_projects(:ecommerce_project)
    skill = skills(:javascript)
    
    project.skills << skill
    assert ProjectSkill.exists?(client_project: project, skill: skill)
  end

  test "should be destroyed when removing skill from project" do
    project = client_projects(:ecommerce_project)
    skill = skills(:ruby)
    
    project_skill = ProjectSkill.create!(client_project: project, skill: skill)
    project.skills.delete(skill)
    assert_not ProjectSkill.exists?(id: project_skill.id)
  end
end

