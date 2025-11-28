require "test_helper"

class Api::V1::ProfileControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_portfolio_user(
      full_name: "John Doe",
      headline: "Senior Developer",
      bio: "Experienced developer",
      location: "San Francisco"
    )
  end

  test "GET /api/v1/profile returns user profile" do
    get api_v1_profile_url
    assert_response :success

    assert_equal "John Doe", json_response["full_name"]
    assert_equal "Senior Developer", json_response["headline"]
  end

  test "GET /api/v1/profile hides email when show_email is false" do
    @user.update!(portfolio_settings: { 'show_email' => false })

    get api_v1_profile_url
    assert_response :success

    assert_nil json_response["email"]
  end

  test "GET /api/v1/profile returns 404 when no user exists" do
    User.destroy_all

    get api_v1_profile_url
    assert_response :not_found
  end

  test "GET /api/v1/profile includes current role and company" do
    @user.work_experiences.create!(
      employer_name: "Acme Corp",
      job_title: "Lead Developer",
      start_date: 6.months.ago
    )

    get api_v1_profile_url
    assert_response :success

    assert_equal "Lead Developer", json_response["current_role"]
    assert_equal "Acme Corp", json_response["current_company"]
  end
end
