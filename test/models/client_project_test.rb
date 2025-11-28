require "test_helper"

class ClientProjectTest < ActiveSupport::TestCase
  def setup
    @project = client_projects(:ecommerce_project)
    @user = users(:portfolio_user)
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    assert @project.valid?
  end

  test "should require name" do
    @project.name = nil
    assert_not @project.valid?
    assert_includes @project.errors[:name], "can't be blank"
  end

  # Association Tests
  test "should belong to user" do
    assert_respond_to @project, :user
    assert_equal @user, @project.user
  end

  test "should have many client_reviews" do
    assert_respond_to @project, :client_reviews
    assert_equal 1, @project.client_reviews.count
  end

  test "should have and belong to many skills" do
    assert_respond_to @project, :skills
  end

  test "should destroy dependent client_reviews when destroyed" do
    review_count_before = ClientReview.count
    @project.destroy
    assert_equal review_count_before - 1, ClientReview.count
  end

  # Auto-assign Tests
  test "should auto-assign to first user on create when user not set" do
    project = ClientProject.new(
      name: "Test Project",
      description: "Test Description"
    )
    project.save
    assert_equal User.first, project.user
  end

  test "should not override user if already set" do
    project = ClientProject.create(
      name: "Test Project",
      description: "Test Description",
      user: @user
    )
    assert_equal @user, project.user
  end
end
