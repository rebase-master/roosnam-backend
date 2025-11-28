require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:portfolio_user)
  end

  # Singleton Pattern Tests
  test "should enforce singleton pattern" do
    new_user = User.new(
      email: "another@example.com",
      password: "password123",
      full_name: "Another User"
    )
    assert_not new_user.valid?
    assert_includes new_user.errors[:base], "Only one user is allowed in this application"
  end

  test "should have admin flag set" do
    # The singleton user should always be admin
    assert @user.admin?
  end

  test "should prevent admin demotion" do
    @user.admin = false
    assert_not @user.valid?
    assert_includes @user.errors[:admin], "cannot be revoked for the portfolio owner"
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should validate presence of full_name when profile fields present" do
    @user.full_name = nil
    @user.headline = "Some headline"
    assert_not @user.valid?
    assert_includes @user.errors[:full_name], "can't be blank"
  end

  test "should not validate full_name when no profile fields present" do
    @user.full_name = nil
    @user.headline = nil
    @user.bio = nil
    @user.location = nil
    assert @user.valid?
  end

  test "should validate availability_status inclusion" do
    @user.availability_status = "invalid_status"
    assert_not @user.valid?
    assert_includes @user.errors[:availability_status], "is not included in the list"
  end

  test "should accept valid availability statuses" do
    %w[available open_to_opportunities not_available].each do |status|
      @user.availability_status = status
      assert @user.valid?, "#{status} should be valid"
    end
  end

  # Association Tests
  test "should have many work experiences" do
    assert_respond_to @user, :work_experiences
    assert_equal 2, @user.work_experiences.count
  end

  test "should have many education records" do
    assert_respond_to @user, :education
    assert_equal 2, @user.education.count
  end

  test "should have many certifications" do
    assert_respond_to @user, :certifications
    assert_equal 2, @user.certifications.count
  end

  test "should have many client projects" do
    assert_respond_to @user, :client_projects
    assert_equal 2, @user.client_projects.count
  end

  test "should have many client reviews" do
    assert_respond_to @user, :client_reviews
    assert_equal 2, @user.client_reviews.count
  end

  # JSON Field Tests
  test "should set default social_links" do
    user = User.new
    assert_equal({}, user.social_links)
  end

  test "should set default portfolio_settings" do
    user = User.new
    expected_settings = {
      'show_email' => true,
      'show_phone' => false,
      'theme_preference' => 'light'
    }
    assert_equal expected_settings, user.portfolio_settings
  end

  # Portfolio Setting Helper Tests
  test "show_email? should return true by default" do
    assert @user.show_email?
  end

  test "show_email? should return false when explicitly set" do
    @user.portfolio_settings['show_email'] = false
    assert_not @user.show_email?
  end

  test "show_phone? should return false by default" do
    assert_not @user.show_phone?
  end

  test "show_phone? should return true when explicitly set" do
    @user.portfolio_settings['show_phone'] = true
    assert @user.show_phone?
  end

  # Current Experience Tests
  test "current_experience should return work experience without end_date" do
    current = @user.current_experience
    assert_not_nil current
    assert_nil current.end_date
    assert_equal "Senior Full Stack Developer", current.job_title
  end

  test "current_role should return job_title of current experience" do
    assert_equal "Senior Full Stack Developer", @user.current_role
  end

  test "current_company_name should return employer_name when no company association" do
    # Since WorkExperience belongs_to :company, optional: true
    # and company is nil, it should return employer_name
    current_exp = @user.current_experience
    assert_not_nil current_exp
    assert_equal "Tech Corp Inc", @user.current_company_name
  end

  test "current_role should return nil when no current experience" do
    @user.work_experiences.update_all(end_date: Date.today)
    assert_nil @user.current_role
  end

  # Display Name Tests
  test "display_name should return display_name when present" do
    assert_equal "John D.", @user.display_name
  end

  test "display_name should fallback to full_name when blank" do
    @user.update(display_name: nil)
    assert_equal "John Doe", @user.display_name
  end

  # Profile Completeness Tests
  test "should calculate profile completeness on save" do
    # Test with existing user - profile completeness should be calculated
    assert @user.profile_completeness >= 0
    assert @user.profile_completeness <= 100
  end

  test "profile completeness should increase with more fields" do
    # Compare existing user's completeness when fields are added
    initial_completeness = @user.profile_completeness

    @user.phone = "555-1234"
    @user.tagline = "A great developer"
    @user.save

    assert @user.profile_completeness >= initial_completeness
  end
end
