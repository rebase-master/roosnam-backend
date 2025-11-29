require "test_helper"

class ApiErrorHandlingTest < ActionDispatch::IntegrationTest
  def setup
    # Clear rack-attack cache to avoid rate limiting between tests
    Rack::Attack.cache.store.clear
  end

  def teardown
    Rack::Attack.cache.store.clear
  end
  # 404 Error Handling
  test "should return 404 for non-existent project" do
    get api_v1_client_project_url(id: 999999), as: :json

    assert_response :not_found
    assert_equal 'application/json; charset=utf-8', response.content_type

    error_response = JSON.parse(response.body)
    assert error_response.key?('error')
    assert_equal 'not_found', error_response['status']
  end

  test "should return 404 with descriptive message" do
    get api_v1_client_project_url(id: 999999), as: :json

    error_response = JSON.parse(response.body)
    assert error_response['error'].include?("Couldn't find") ||
           error_response['error'].include?("not found"),
           "Error message should describe the not found error"
  end

  # Malformed Request Handling
  test "should handle requests without json format gracefully" do
    # Test that API still works with explicit json format
    get api_v1_profile_url, as: :json
    assert_response :success

    # Test HTML format request (should still return JSON in API-only mode)
    get api_v1_profile_url
    assert_response :success
  end

  # Empty Response Handling
  test "should return empty array for resources with no data" do
    # Clear all client reviews temporarily
    ClientReview.destroy_all

    get api_v1_client_reviews_url, as: :json
    assert_response :success

    reviews = JSON.parse(response.body)
    assert_equal [], reviews
  end

  # Rate Limiting Error Responses
  test "should return proper error format when rate limited" do
    # Trigger rate limit by making 101 requests
    101.times { get api_v1_profile_url, as: :json }

    # Last request should be rate limited
    assert_response :too_many_requests

    error_response = JSON.parse(response.body)
    assert_equal 'Rate limit exceeded. Please try again later.', error_response['error']
    assert error_response.key?('retry_after')
  end

  # CORS and Headers
  test "should include proper headers for API requests" do
    get api_v1_profile_url, as: :json

    assert_response :success
    assert_equal 'application/json; charset=utf-8', response.content_type
  end

  # Serialization Errors
  test "should handle missing associations gracefully" do
    # Get all endpoints and verify no serialization errors
    endpoints = [
      api_v1_profile_url,
      api_v1_work_experiences_url,
      api_v1_skills_url,
      api_v1_education_index_url,
      api_v1_certifications_url,
      api_v1_client_projects_url,
      api_v1_client_reviews_url
    ]

    endpoints.each do |url|
      get url, as: :json
      assert_response :success, "#{url} should not raise serialization errors"

      # Verify response is valid JSON
      assert_nothing_raised do
        JSON.parse(response.body)
      end
    end
  end

  # Null/Empty Data Handling
  test "should handle null values in serialized data" do
    get api_v1_work_experiences_url, as: :json
    assert_response :success

    experiences = JSON.parse(response.body)
    experiences.each do |exp|
      # Verify structure even with nil values
      assert exp.key?('end_date') # Can be null for current positions
      assert exp.key?('city') # Can be null
      assert exp.key?('state') # Can be null
      assert exp.key?('country') # Can be null
    end
  end

  test "should handle profile without optional attachments" do
    user = users(:portfolio_user)
    user.profile_photo.purge if user.profile_photo.attached?
    user.resume.purge if user.resume.attached?

    get api_v1_profile_url, as: :json
    assert_response :success

    profile = JSON.parse(response.body)
    assert_nil profile['profile_photo_url']
    assert_nil profile['resume_url']
  end

  test "should handle education without certificate attachment" do
    Education.all.each do |edu|
      edu.certificate.purge if edu.certificate.attached?
    end

    get api_v1_education_index_url, as: :json
    assert_response :success

    education = JSON.parse(response.body)
    education.each do |edu|
      assert_nil edu['certificate_url']
    end
  end

  test "should handle certification without document attachment" do
    Certification.all.each do |cert|
      cert.document.purge if cert.document.attached?
    end

    get api_v1_certifications_url, as: :json
    assert_response :success

    certifications = JSON.parse(response.body)
    certifications.each do |cert|
      assert_nil cert['document_url']
    end
  end

  # Concurrent Request Handling
  test "should handle multiple sequential requests correctly" do
    # Integration tests don't support true concurrency well
    # Test sequential requests instead to verify no state issues
    5.times do
      get api_v1_profile_url, as: :json
      assert_response :success
    end
  end

  # Edge Case: Empty Portfolio
  test "should handle user with no work experiences" do
    user = users(:portfolio_user)
    user.work_experiences.each { |we| we.skills.destroy_all }
    user.work_experiences.destroy_all

    get api_v1_work_experiences_url, as: :json
    assert_response :success

    experiences = JSON.parse(response.body)
    assert_equal [], experiences
  end

  test "should handle user with no education" do
    Education.destroy_all

    get api_v1_education_index_url, as: :json
    assert_response :success

    education = JSON.parse(response.body)
    assert_equal [], education
  end

  # API Consistency Tests
  test "should maintain consistent response structure across errors" do
    # 404 error
    get api_v1_client_project_url(id: 999999), as: :json
    error_404 = JSON.parse(response.body)

    assert error_404.key?('error')
    assert error_404.key?('status')

    # Both errors should have consistent structure
    assert error_404['error'].is_a?(String)
    assert error_404['status'].is_a?(String)
  end

  # Special Characters and Encoding
  test "should handle special characters in API responses" do
    get api_v1_profile_url, as: :json
    assert_response :success

    # Verify response is valid UTF-8 JSON
    assert response.body.valid_encoding?, "Response should be valid UTF-8"
  end
end
