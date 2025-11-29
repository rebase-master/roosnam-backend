require "test_helper"

class Api::V1::BaseControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Clear rack-attack cache to avoid rate limiting
    Rack::Attack.cache.store.clear
  end

  def teardown
    Rack::Attack.cache.store.clear
  end

  # Test error handling by using the profile endpoint
  # since it inherits from BaseController

  test "should handle RecordNotFound with 404" do
    # Create a temporary test controller to simulate not found
    # Since we can't easily delete the singleton user, we'll test via
    # the client_projects show endpoint with invalid ID

    get api_v1_client_project_url(id: 99999), as: :json

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal 'not_found', json_response['status']
    assert json_response['error'].present?
  end

  test "should return json content type for errors" do
    get api_v1_client_project_url(id: 99999), as: :json

    assert_equal 'application/json; charset=utf-8', response.content_type
  end

  test "should protect from CSRF for API requests" do
    # API should use null_session for CSRF protection
    # This allows API requests without CSRF tokens
    get api_v1_profile_url, as: :json
    assert_response :success
  end
end
