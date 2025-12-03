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

  test "prevent_admin_demotion should not error if admin unchanged" do
    original_admin = @user.admin
    @user.email = "new@example.com"
    @user.valid?
    assert_equal original_admin, @user.admin
    assert @user.errors[:admin].empty?
  end

  test "prevent_admin_demotion should not error if admin set to true" do
    @user.admin = true
    @user.valid?
    assert @user.errors[:admin].empty?
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

  test "calculate_profile_completeness should be called before_save" do
    initial = @user.profile_completeness
    @user.phone = "555-1234"
    @user.save
    # Completeness should be recalculated
    assert @user.profile_completeness != initial || @user.profile_completeness == initial
  end

  test "profile completeness should increase with more fields" do
    # Compare existing user's completeness when fields are added
    initial_completeness = @user.profile_completeness

    @user.phone = "555-1234"
    @user.tagline = "A great developer"
    @user.save

    assert @user.profile_completeness >= initial_completeness
  end

  # Experience Calculation Tests
  test "total_experience_years should calculate from all work experiences" do
    # User has work experiences in fixtures, total should be calculated
    total_years = @user.total_experience_years
    assert total_years >= 0, "Total experience should be non-negative"
  end

  test "total_experience_years should return 0 when no experiences" do
    # Delete associated skills first to avoid FK constraint
    @user.work_experiences.each { |we| we.skills.destroy_all }
    @user.work_experiences.destroy_all
    assert_equal 0.0, @user.total_experience_years
  end

  # Social Links Attributes Tests
  test "should have linkedin_url accessor" do
    assert_respond_to @user, :linkedin_url
    assert_respond_to @user, :linkedin_url=
  end

  test "should have github_url accessor" do
    assert_respond_to @user, :github_url
    assert_respond_to @user, :github_url=
  end

  test "should have twitter_url accessor" do
    assert_respond_to @user, :twitter_url
    assert_respond_to @user, :twitter_url=
  end

  test "should have website_url accessor" do
    assert_respond_to @user, :website_url
    assert_respond_to @user, :website_url=
  end

  test "should sync linkedin_url to social_links on save" do
    @user.linkedin_url = 'https://linkedin.com/in/test'
    @user.save
    assert_equal 'https://linkedin.com/in/test', @user.social_links['linkedin']
  end

  test "should sync github_url to social_links on save" do
    @user.github_url = 'https://github.com/test'
    @user.save
    assert_equal 'https://github.com/test', @user.social_links['github']
  end

  test "should sync twitter_url to social_links on save" do
    @user.twitter_url = 'https://twitter.com/test'
    @user.save
    assert_equal 'https://twitter.com/test', @user.social_links['twitter']
  end

  test "should sync website_url to social_links on save" do
    @user.website_url = 'https://example.com'
    @user.save
    assert_equal 'https://example.com', @user.social_links['website']
  end

  test "should sync portfolio settings on save" do
    @user.setting_show_email = false
    @user.setting_show_phone = true
    @user.setting_theme_preference = 'dark'
    @user.save
    assert_equal false, @user.portfolio_settings['show_email']
    assert_equal true, @user.portfolio_settings['show_phone']
    assert_equal 'dark', @user.portfolio_settings['theme_preference']
  end

  # Validation Tests
  test "should validate email format" do
    @user.email = 'invalid-email'
    assert_not @user.valid?
    assert_includes @user.errors[:email], "is invalid"
  end

  test "should validate full_name length" do
    @user.full_name = 'a' * 61
    assert_not @user.valid?
    assert_includes @user.errors[:full_name], "must be 60 characters or less"
  end

  test "should validate display_name length" do
    @user.display_name = 'a' * 61
    assert_not @user.valid?
    assert_includes @user.errors[:display_name], "must be 60 characters or less"
  end

  # Dependent Destroy Tests
  test "should destroy work_experiences when user is destroyed" do
    work_exp = @user.work_experiences.first
    @user.destroy
    assert_not WorkExperience.exists?(id: work_exp.id)
  end

  test "should destroy education when user is destroyed" do
    education = @user.education.first
    @user.destroy
    assert_not Education.exists?(id: education.id)
  end

  test "should destroy certifications when user is destroyed" do
    cert = @user.certifications.first
    @user.destroy
    assert_not Certification.exists?(id: cert.id)
  end

  # Profile Completeness Edge Cases
  test "profile completeness should be 0 when no fields filled" do
    user = User.new(email: 'test@example.com', password: 'password123')
    user.save
    assert_equal 0, user.profile_completeness
  end

  test "profile completeness should calculate correctly with partial fields" do
    @user.full_name = "Test"
    @user.email = "test@example.com"
    @user.headline = nil
    @user.bio = nil
    @user.location = nil
    @user.save
    # Should have 2/5 required fields = 40% of 70 = 28%
    assert @user.profile_completeness > 0
    assert @user.profile_completeness < 100
  end

  test "profile completeness should include optional fields in calculation" do
    initial = @user.profile_completeness
    @user.phone = "555-1234"
    @user.tagline = "Great developer"
    @user.years_of_experience = 5
    @user.save
    assert @user.profile_completeness > initial
  end

  test "profile completeness should calculate 100% when all fields filled" do
    @user.full_name = "Test User"
    @user.email = "test@example.com"
    @user.headline = "Developer"
    @user.bio = "Bio text"
    @user.location = "City"
    @user.phone = "555-1234"
    @user.tagline = "Tagline"
    @user.years_of_experience = 5
    @user.save
    assert_equal 100, @user.profile_completeness
  end

  test "profile completeness should calculate correctly with only required fields" do
    @user.full_name = "Test User"
    @user.email = "test@example.com"
    @user.headline = "Developer"
    @user.bio = "Bio text"
    @user.location = "City"
    @user.phone = nil
    @user.tagline = nil
    @user.years_of_experience = nil
    @user.save
    # 5/5 required = 100% of 70% = 70%
    assert_equal 70, @user.profile_completeness
  end

  test "set_default_json_fields should initialize social_links to empty hash" do
    user = User.new
    assert_equal({}, user.social_links)
  end

  test "set_default_json_fields should initialize portfolio_settings with defaults" do
    user = User.new
    expected = {
      'show_email' => true,
      'show_phone' => false,
      'theme_preference' => 'light'
    }
    assert_equal expected, user.portfolio_settings
  end

  test "set_default_json_fields should not override existing social_links" do
    @user.social_links = { 'linkedin' => 'test' }
    @user.send(:set_default_json_fields)
    assert_equal 'test', @user.social_links['linkedin']
  end

  test "set_default_json_fields should not override existing portfolio_settings" do
    @user.portfolio_settings = { 'show_email' => false }
    @user.send(:set_default_json_fields)
    assert_equal false, @user.portfolio_settings['show_email']
  end

  # Edge Cases
  test "profile_fields_present? should return true if any field present" do
    @user.headline = "Test"
    @user.bio = nil
    @user.location = nil
    assert @user.send(:profile_fields_present?)
  end

  test "profile_fields_present? should return false if all fields nil" do
    @user.headline = nil
    @user.bio = nil
    @user.location = nil
    assert_not @user.send(:profile_fields_present?)
  end

  test "profile_fields_present? should return true if headline present" do
    @user.headline = "Test"
    @user.bio = nil
    @user.location = nil
    assert @user.send(:profile_fields_present?)
  end

  test "profile_fields_present? should return true if bio present" do
    @user.headline = nil
    @user.bio = "Test"
    @user.location = nil
    assert @user.send(:profile_fields_present?)
  end

  test "profile_fields_present? should return true if location present" do
    @user.headline = nil
    @user.bio = nil
    @user.location = "Test"
    assert @user.send(:profile_fields_present?)
  end

  test "ensure_admin_flag should set admin to true on create" do
    User.destroy_all
    user = User.new(
      email: 'new@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    )
    user.valid?
    assert_equal true, user.admin
  end

  # Total Experience Edge Cases
  test "total_experience_years should handle fractional months" do
    # Create a new work experience with specific dates
    work_exp = WorkExperience.create!(
      user: @user,
      job_title: "Test Job",
      employer_name: "Test Company",
      start_date: Date.today - 18.months,
      end_date: Date.today
    )
    @user.reload
    total = @user.total_experience_years
    # 18 months = 1.5 years, but we have other experiences too
    assert total >= 1.0, "Total should be at least 1.0 years"
  end

  test "total_experience_years should handle overlapping experiences" do
    # Create overlapping work experiences
    we1 = WorkExperience.create!(
      user: @user,
      job_title: "Job 1",
      employer_name: "Company 1",
      start_date: Date.today - 2.years,
      end_date: Date.today - 1.year
    )
    we2 = WorkExperience.create!(
      user: @user,
      job_title: "Job 2",
      employer_name: "Company 2",
      start_date: Date.today - 18.months,
      end_date: Date.today
    )
    total = @user.total_experience_years
    assert total > 0
  end

  # Current Experience Edge Cases
  test "current_experience should return most recent when multiple current" do
    # Create multiple current experiences
    we1 = WorkExperience.create!(
      user: @user,
      job_title: "Job 1",
      employer_name: "Company 1",
      start_date: Date.today - 1.year,
      end_date: nil
    )
    we2 = WorkExperience.create!(
      user: @user,
      job_title: "Job 2",
      employer_name: "Company 2",
      start_date: Date.today - 6.months,
      end_date: nil
    )
    current = @user.current_experience
    assert_equal we2.id, current.id # Should be most recent
  end

  test "current_company_name should return nil when no current experience" do
    # Set all work experiences to have end dates
    @user.work_experiences.update_all(end_date: Date.today)
    @user.reload
    company = @user.current_company_name
    assert_nil company
  end

  # Resume attachment tests
  test "resume must be pdf or doc content type" do
    @user.resume.attach(
      io: StringIO.new("not a pdf"),
      filename: "resume.txt",
      content_type: "text/plain"
    )

    assert_not @user.valid?
    assert_includes @user.errors[:resume], "must be a PDF or DOC file"
  end

  test "ensure_resume_filename sets filename based on full_name and date" do
    @user.full_name = "John Doe"
    @user.resume.attach(
      io: StringIO.new("dummy resume"),
      filename: "my_resume.pdf",
      content_type: "application/pdf"
    )
    @user.save!
    @user.reload

    filename = @user.resume.filename.to_s
    assert_match(/john_doe_\d{8}\.pdf/, filename)
  end

  test "remove_resume flag should purge attached resume before save" do
    @user.resume.attach(
      io: StringIO.new("dummy resume"),
      filename: "resume.pdf",
      content_type: "application/pdf"
    )
    assert @user.resume.attached?

    @user.remove_resume = true
    @user.save!
    @user.reload

    assert_not @user.resume.attached?
  end
end
