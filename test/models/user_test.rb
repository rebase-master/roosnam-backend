require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    User.destroy_all
  end

  test "enforces singleton pattern" do
    user1 = User.create!(
      email: "first@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    assert user1.persisted?

    user2 = User.new(
      email: "second@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    assert_not user2.valid?
    assert_includes user2.errors[:base], "Only one user is allowed in this application"
  end

  test "automatically sets admin flag on create" do
    user = User.create!(
      email: "admin@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    assert user.admin?
  end

  test "prevents admin demotion" do
    user = create_portfolio_user
    user.admin = false
    assert_not user.valid?
    assert_includes user.errors[:admin], "cannot be revoked for the portfolio owner"
  end

  test "calculates profile completeness" do
    user = create_portfolio_user(
      full_name: "Complete User",
      headline: "Developer",
      bio: "A bio",
      location: "City"
    )
    # email + full_name + headline + bio + location = 5/5 required = 70%
    # no optional fields = 0%
    assert_equal 70, user.profile_completeness
  end

  test "current_experience returns latest ongoing work" do
    user = create_portfolio_user
    
    past_exp = user.work_experiences.create!(
      employer_name: "Old Company",
      job_title: "Junior Dev",
      start_date: 2.years.ago,
      end_date: 1.year.ago
    )
    
    current_exp = user.work_experiences.create!(
      employer_name: "Current Company",
      job_title: "Senior Dev",
      start_date: 1.year.ago,
      end_date: nil
    )

    assert_equal current_exp, user.current_experience
    assert_equal "Senior Dev", user.current_role
    assert_equal "Current Company", user.current_company_name
  end

  test "show_email respects portfolio_settings" do
    user = create_portfolio_user
    assert user.show_email? # default true

    user.portfolio_settings['show_email'] = false
    assert_not user.show_email?
  end

  test "show_phone respects portfolio_settings" do
    user = create_portfolio_user
    assert_not user.show_phone? # default false

    user.portfolio_settings['show_phone'] = true
    assert user.show_phone?
  end
end
