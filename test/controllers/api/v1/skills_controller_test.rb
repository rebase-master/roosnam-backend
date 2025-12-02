require "test_helper"

class Api::V1::SkillsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:portfolio_user)
    @skill = skills(:ruby)
  end

  test "should get index" do
    get api_v1_skills_url, as: :json
    assert_response :success
  end

  test "should return json content type" do
    get api_v1_skills_url, as: :json
    assert_equal 'application/json; charset=utf-8', response.content_type
  end

  test "should return skills ordered by years_of_experience desc then name asc" do
    get api_v1_skills_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array)
  end

  test "should return skills from user's work experiences and client projects" do
    # Create a project with a skill
    project = client_projects(:ecommerce_project)
    skill = skills(:ruby)
    ProjectSkill.create!(client_project: project, skill: skill)

    get api_v1_skills_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array)
    
    # Verify skills come from either work experiences or client projects
    skill_ids = json_response.map { |s| s['id'] }
    assert_includes skill_ids, skill.id
  end

  test "should handle user with no skills" do
    Skill.destroy_all

    get api_v1_skills_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal [], json_response
  end

  test "should return skills with source_company from work experiences" do
    work_exp = work_experiences(:current_job)
    skill = skills(:ruby)
    skill.update(work_experience: work_exp)

    get api_v1_skills_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    skill_json = json_response.find { |s| s['id'] == skill.id }
    assert_not_nil skill_json
    assert_equal work_exp.employer_name, skill_json['source_company']
  end

  test "should return distinct skills when skill appears in both work experience and project" do
    work_exp = work_experiences(:current_job)
    project = client_projects(:ecommerce_project)
    skill = skills(:ruby)
    
    skill.update(work_experience: work_exp)
    ProjectSkill.create!(client_project: project, skill: skill)

    get api_v1_skills_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    skill_ids = json_response.map { |s| s['id'] }
    assert_equal 1, skill_ids.count(skill.id), "Skill should appear only once"
  end

  test "should order skills by years_of_experience desc then name asc" do
    skill1 = skills(:ruby)
    skill2 = skills(:javascript)
    skill1.update(years_of_experience: 5)
    skill2.update(years_of_experience: 10)

    work_exp = work_experiences(:current_job)
    skill1.update(work_experience: work_exp)
    skill2.update(work_experience: work_exp)

    get api_v1_skills_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    skill_ids = json_response.map { |s| s['id'] }
    skill2_index = skill_ids.index(skill2.id)
    skill1_index = skill_ids.index(skill1.id)
    
    assert skill2_index < skill1_index, "Skill with more experience should come first"
  end
end
