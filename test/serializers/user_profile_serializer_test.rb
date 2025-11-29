require "test_helper"

class UserProfileSerializerTest < ActiveSupport::TestCase
  def setup
    @user = users(:portfolio_user)
    @serializer = UserProfileSerializer.new(@user)
    @serialization = @serializer.serializable_hash
  end

  test "should include all required attributes" do
    expected_keys = %i[
      id full_name display_name email phone headline bio tagline
      location timezone years_of_experience current_role current_company
      availability_status hourly_rate social_links profile_photo_url
      resume_url seo_title seo_description profile_completeness
    ]

    expected_keys.each do |key|
      assert @serialization.key?(key), "Missing attribute: #{key}"
    end
  end

  test "should return email when show_email is true" do
    @user.portfolio_settings['show_email'] = true
    serializer = UserProfileSerializer.new(@user)
    serialization = serializer.serializable_hash

    assert_equal @user.email, serialization[:email]
  end

  test "should hide email when show_email is false" do
    @user.portfolio_settings['show_email'] = false
    serializer = UserProfileSerializer.new(@user)
    serialization = serializer.serializable_hash

    assert_nil serialization[:email]
  end

  test "should return phone when show_phone is true" do
    @user.portfolio_settings['show_phone'] = true
    @user.phone = '555-1234'
    serializer = UserProfileSerializer.new(@user)
    serialization = serializer.serializable_hash

    assert_equal @user.phone, serialization[:phone]
  end

  test "should hide phone when show_phone is false" do
    @user.portfolio_settings['show_phone'] = false
    @user.phone = '555-1234'
    serializer = UserProfileSerializer.new(@user)
    serialization = serializer.serializable_hash

    assert_nil serialization[:phone]
  end

  test "should return current_company from method" do
    assert_equal @user.current_company_name, @serialization[:current_company]
  end

  test "should return nil for profile_photo_url when not attached" do
    @user.profile_photo.purge if @user.profile_photo.attached?
    serializer = UserProfileSerializer.new(@user)
    serialization = serializer.serializable_hash

    assert_nil serialization[:profile_photo_url]
  end

  test "should return nil for resume_url when not attached" do
    @user.resume.purge if @user.resume.attached?
    serializer = UserProfileSerializer.new(@user)
    serialization = serializer.serializable_hash

    assert_nil serialization[:resume_url]
  end
end
