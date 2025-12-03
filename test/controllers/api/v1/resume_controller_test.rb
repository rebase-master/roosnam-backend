require "test_helper"

class Api::V1::ResumeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:portfolio_user)
  end

  test "should return 404 when resume not attached" do
    @user.resume.purge if @user.resume.attached?

    get api_v1_resume_url
    assert_response :not_found

    json = JSON.parse(response.body)
    assert_equal "not_found", json["status"]
  end
end
