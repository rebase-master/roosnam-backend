require "test_helper"

class ClientReviewTest < ActiveSupport::TestCase
  def setup
    @review = client_reviews(:ecommerce_review)
    @user = users(:portfolio_user)
    @project = client_projects(:ecommerce_project)
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    assert @review.valid?
  end

  test "should require reviewer_name" do
    @review.reviewer_name = nil
    assert_not @review.valid?
    assert_includes @review.errors[:reviewer_name], "can't be blank"
  end

  test "should require review_text" do
    @review.review_text = nil
    assert_not @review.valid?
    assert_includes @review.errors[:review_text], "can't be blank"
  end

  test "should validate rating is between 1 and 5" do
    @review.rating = 0
    assert_not @review.valid?
    assert_includes @review.errors[:rating], "must be in 1..5"

    @review.rating = 6
    assert_not @review.valid?
    assert_includes @review.errors[:rating], "must be in 1..5"
  end

  test "should accept valid ratings from 1 to 5" do
    (1..5).each do |rating|
      @review.rating = rating
      assert @review.valid?, "Rating #{rating} should be valid"
    end
  end

  test "should allow nil rating" do
    @review.rating = nil
    assert @review.valid?
  end

  # Association Tests
  test "should belong to client_project" do
    assert_respond_to @review, :client_project
    assert_equal @project, @review.client_project
  end

  test "should belong to user" do
    assert_respond_to @review, :user
    assert_equal @user, @review.user
  end
end
