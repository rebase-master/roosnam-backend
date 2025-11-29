require "test_helper"

class ClientReviewSerializerTest < ActiveSupport::TestCase
  def setup
    @review = client_reviews(:ecommerce_review)
    @serializer = ClientReviewSerializer.new(@review)
    @serialization = @serializer.serializable_hash
  end

  test "should include all required attributes" do
    expected_keys = %i[
      id reviewer_name reviewer_position reviewer_company
      review_text rating client_project_id created_at reviewer_display_name
    ]

    expected_keys.each do |key|
      assert @serialization.key?(key), "Missing attribute: #{key}"
    end
  end

  test "should include reviewer_display_name" do
    assert @serialization.key?(:reviewer_display_name)
    assert_equal @review.reviewer_display_name, @serialization[:reviewer_display_name]
  end

  test "reviewer_display_name should include company when present" do
    @review.reviewer_name = "John Doe"
    @review.reviewer_position = "CEO"
    @review.reviewer_company = "Acme Corp"

    serializer = ClientReviewSerializer.new(@review)
    serialization = serializer.serializable_hash

    expected = "John Doe, CEO at Acme Corp"
    assert_equal expected, serialization[:reviewer_display_name]
  end

  test "reviewer_display_name should work without company" do
    @review.reviewer_name = "Jane Smith"
    @review.reviewer_position = "Manager"
    @review.reviewer_company = nil

    serializer = ClientReviewSerializer.new(@review)
    serialization = serializer.serializable_hash

    expected = "Jane Smith, Manager"
    assert_equal expected, serialization[:reviewer_display_name]
  end

  test "reviewer_display_name should work with only name" do
    @review.reviewer_name = "Bob Johnson"
    @review.reviewer_position = nil
    @review.reviewer_company = nil

    serializer = ClientReviewSerializer.new(@review)
    serialization = serializer.serializable_hash

    assert_equal "Bob Johnson", serialization[:reviewer_display_name]
  end
end
