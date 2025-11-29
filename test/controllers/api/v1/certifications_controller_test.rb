require "test_helper"

class Api::V1::CertificationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:portfolio_user)
    @certification = certifications(:aws_cert)
  end

  test "should get index" do
    get api_v1_certifications_url, as: :json
    assert_response :success
  end

  test "should return json content type" do
    get api_v1_certifications_url, as: :json
    assert_equal 'application/json; charset=utf-8', response.content_type
  end

  test "should return certifications ordered by issue_date desc" do
    get api_v1_certifications_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array)
    assert json_response.length > 0
  end

  test "should return only user's certifications" do
    get api_v1_certifications_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @user.certifications.count, json_response.length
  end

  test "should handle empty certifications" do
    @user.certifications.destroy_all

    get api_v1_certifications_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal [], json_response
  end
end
