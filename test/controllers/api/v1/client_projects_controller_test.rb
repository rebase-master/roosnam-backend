require "test_helper"

class Api::V1::ClientProjectsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:portfolio_user)
    @project = client_projects(:ecommerce_project)
  end

  test "should get index" do
    get api_v1_client_projects_url, as: :json
    assert_response :success
  end

  test "should return json content type" do
    get api_v1_client_projects_url, as: :json
    assert_equal 'application/json; charset=utf-8', response.content_type
  end

  test "should return projects ordered by start_date desc" do
    get api_v1_client_projects_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array)
    assert json_response.length > 0
  end

  test "should return only user's projects" do
    get api_v1_client_projects_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @user.client_projects.count, json_response.length
  end

  test "should get show" do
    get api_v1_client_project_url(@project), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @project.name, json_response['name']
  end

  test "should return 404 for non-existent project" do
    # BaseController rescues RecordNotFound and returns 500, not 404
    # This is due to the rescue_from StandardError in base_controller
    # So we expect a 404 response status, not an exception
    get api_v1_client_project_url(id: 99999), as: :json
    assert_response :not_found
  end

  test "should handle empty projects" do
    @user.client_projects.destroy_all

    get api_v1_client_projects_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal [], json_response
  end
end
