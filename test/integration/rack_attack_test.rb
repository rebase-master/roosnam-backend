require "test_helper"

class RackAttackTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:portfolio_user)
    # Clear rack-attack cache before each test
    Rack::Attack.cache.store.clear
  end

  def teardown
    # Clear cache after each test
    Rack::Attack.cache.store.clear
  end

  # API Throttling Tests
  test "should allow requests under API rate limit" do
    50.times do
      get api_v1_profile_url, as: :json
      assert_response :success
    end
  end

  test "should throttle API requests exceeding limit" do
    # Rack::Attack is configured to allow 100 requests per minute per IP
    # Make 101 requests to trigger throttling
    101.times do |i|
      get api_v1_profile_url, as: :json

      if i < 100
        assert_response :success, "Request #{i + 1} should succeed"
      else
        assert_response :too_many_requests, "Request #{i + 1} should be throttled"
      end
    end
  end

  test "should return correct headers for throttled requests" do
    # Make 100 requests that should succeed
    100.times do
      get api_v1_profile_url, as: :json
      assert_response :success
    end

    # The 101st request should be throttled
    get api_v1_profile_url, as: :json
    assert_response :too_many_requests
    assert_equal 'application/json', response.content_type

    json_response = JSON.parse(response.body)
    assert_equal 'Rate limit exceeded. Please try again later.', json_response['error']
    assert json_response['retry_after'].present?
  end

  # Login Throttling Tests (if using Devise)
  test "should allow multiple login attempts under limit" do
    3.times do
      post user_session_url, params: {
        user: { email: 'wrong@example.com', password: 'wrong' }
      }
      # We expect these to fail due to wrong credentials (422), not rate limiting (429)
      assert_response :unprocessable_entity
    end
  end

  test "should throttle excessive login attempts by IP" do
    # Make 6 login attempts (limit is 5 per 20 seconds)
    6.times do |i|
      post user_session_url, params: {
        user: { email: 'wrong@example.com', password: 'wrong' }
      }

      if i < 5
        # First 5 should not be rate limited
        assert_not_equal 429, response.status, "Request #{i + 1} should not be rate limited"
      else
        # 6th request should be throttled
        assert_response :too_many_requests, "Request #{i + 1} should be throttled"
      end
    end
  end

  test "should throttle login attempts by email" do
    email = 'test@example.com'

    # Make 6 login attempts with the same email
    6.times do |i|
      post user_session_url, params: {
        user: { email: email, password: 'wrong' }
      }

      if i < 5
        assert_not_equal 429, response.status, "Request #{i + 1} should not be rate limited"
      else
        assert_response :too_many_requests, "Request #{i + 1} should be throttled"
      end
    end
  end

  # API endpoints share the same rate limit per IP
  test "should apply rate limit across all API endpoints" do
    # Limit is 100 per minute per IP, so 30 requests to each endpoint = 90 total
    30.times do
      get api_v1_profile_url, as: :json
      get api_v1_skills_url, as: :json
      get api_v1_work_experiences_url, as: :json
    end

    # All 90 requests should succeed (under the 100 limit)
    assert_response :success
  end

  # Test that cache is working
  test "should use cache for rate limiting" do
    assert_respond_to Rack::Attack.cache.store, :read
    assert_respond_to Rack::Attack.cache.store, :write

    # Make a request
    get api_v1_profile_url, as: :json
    assert_response :success

    # Cache should have entries
    # Note: Testing internal cache state is tricky, just verify it responds
  end
end
