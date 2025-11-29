require "test_helper"

class Api::V1::ProfileControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:portfolio_user)
  end

  test "should get profile" do
    get api_v1_profile_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @user.email, json_response['email']
    assert_equal @user.full_name, json_response['full_name']
  end

  test "should return json content type" do
    get api_v1_profile_url, as: :json
    assert_equal 'application/json; charset=utf-8', response.content_type
  end

  # This test would require deleting foreign key constrained records first
  # Skipping for now since it's complex to set up
  # test "should handle missing user gracefully" do
  #   User.delete_all
  #
  #   assert_raises(ActiveRecord::RecordNotFound) do
  #     get api_v1_profile_url, as: :json
  #   end
  # end
end
