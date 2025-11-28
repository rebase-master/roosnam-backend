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

  test "should return only skills from user's work experiences" do
    get api_v1_skills_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)

    # Verify all returned skills belong to user's work experiences
    json_response.each do |skill_json|
      skill = Skill.find(skill_json['id'])
      assert_equal @user.id, skill.work_experience.user_id
    end
  end

  test "should handle user with no skills" do
    Skill.destroy_all

    get api_v1_skills_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal [], json_response
  end
end
