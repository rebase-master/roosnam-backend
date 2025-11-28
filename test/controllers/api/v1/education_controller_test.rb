require "test_helper"

class Api::V1::EducationControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:portfolio_user)
    @education = education(:bachelor)
  end

  test "should get index" do
    get api_v1_education_index_url, as: :json
    assert_response :success
  end

  test "should return json content type" do
    get api_v1_education_index_url, as: :json
    assert_equal 'application/json; charset=utf-8', response.content_type
  end

  test "should return education ordered by end_year desc" do
    get api_v1_education_index_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array)
    assert json_response.length > 0
  end

  test "should return only user's education records" do
    get api_v1_education_index_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @user.education.count, json_response.length
  end

  test "should handle empty education" do
    @user.education.destroy_all

    get api_v1_education_index_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal [], json_response
  end
end
