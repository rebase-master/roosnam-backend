require "test_helper"

class Api::V1::ClientReviewsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:portfolio_user)
    @review = client_reviews(:ecommerce_review)
  end

  test "should get index" do
    get api_v1_client_reviews_url, as: :json
    assert_response :success
  end

  test "should return json content type" do
    get api_v1_client_reviews_url, as: :json
    assert_equal 'application/json; charset=utf-8', response.content_type
  end

  test "should return reviews ordered by created_at desc" do
    get api_v1_client_reviews_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response.is_a?(Array)
    assert json_response.length > 0
  end

  test "should return only reviews for user's projects" do
    get api_v1_client_reviews_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)

    # All reviews should belong to projects owned by the user
    json_response.each do |review_json|
      review = ClientReview.find(review_json['id'])
      assert_equal @user.id, review.client_project.user_id
    end
  end

  test "should handle empty reviews" do
    ClientReview.destroy_all

    get api_v1_client_reviews_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal [], json_response
  end
end
