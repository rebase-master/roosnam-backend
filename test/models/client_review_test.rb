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

  # Scope Tests
  test "positive scope should return reviews with rating >= 4" do
    positive_reviews = ClientReview.positive
    positive_reviews.each do |review|
      assert review.rating >= 4, "Positive reviews should have rating >= 4"
    end
  end

  test "with_rating scope should return reviews with non-nil rating" do
    rated_reviews = ClientReview.with_rating
    rated_reviews.each do |review|
      assert_not_nil review.rating, "Rated reviews should have non-nil rating"
    end
  end

  # Method Tests
  test "reviewer_display_name should return reviewer_name when no company or position" do
    @review.reviewer_company = nil
    @review.reviewer_position = nil
    assert_equal @review.reviewer_name, @review.reviewer_display_name
  end

  test "reviewer_display_name should include position when present" do
    @review.reviewer_company = nil
    @review.reviewer_position = "CTO"
    expected = "#{@review.reviewer_name}, #{@review.reviewer_position}"
    assert_equal expected, @review.reviewer_display_name
  end

  test "reviewer_display_name should include company and position when both present" do
    @review.reviewer_company = "Tech Corp"
    @review.reviewer_position = "CTO"
    expected = "#{@review.reviewer_name}, #{@review.reviewer_position} at #{@review.reviewer_company}"
    assert_equal expected, @review.reviewer_display_name
  end

  # Auto-assign Tests
  test "should auto-assign to first user on create when user not set" do
    review = ClientReview.new(
      reviewer_name: "Test Reviewer",
      review_text: "Great work!",
      client_project: @project
    )
    review.save
    assert_equal User.first, review.user
  end
end
