require "test_helper"

class EducationTest < ActiveSupport::TestCase
  def setup
    @education = education(:bachelor)
    @user = users(:portfolio_user)
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    assert @education.valid?
  end

  test "should require school_name" do
    @education.school_name = nil
    assert_not @education.valid?
    assert_includes @education.errors[:school_name], "can't be blank"
  end

  test "should require degree" do
    @education.degree = nil
    assert_not @education.valid?
    assert_includes @education.errors[:degree], "can't be blank"
  end

  test "should have degree_status after validation" do
    # Model sets default to now_attending if blank via before_validation
    @education.degree_status = nil
    @education.valid?
    assert_not_nil @education.degree_status
  end

  test "should require field_of_study" do
    @education.field_of_study = nil
    assert_not @education.valid?
    assert_includes @education.errors[:field_of_study], "can't be blank"
  end

  test "should require start_year" do
    @education.start_year = nil
    assert_not @education.valid?
    assert_includes @education.errors[:start_year], "can't be blank"
  end

  test "should require end_year unless now_attending" do
    @education.degree_status = 'graduated'
    @education.end_year = nil
    assert_not @education.valid?
    assert_includes @education.errors[:end_year], "can't be blank"
  end

  test "should allow nil end_year when now_attending" do
    @education.degree_status = 'now_attending'
    @education.end_year = nil
    assert @education.valid?
  end

  # Year Validation Tests
  test "should validate start_year is greater than 1900" do
    @education.start_year = 1899
    assert_not @education.valid?
    assert_includes @education.errors[:start_year], "must be greater than 1900"
  end

  test "should validate start_year is less than or equal to 2100" do
    @education.start_year = 2101
    assert_not @education.valid?
    assert_includes @education.errors[:start_year], "must be less than or equal to 2100"
  end

  test "should validate end_year is greater than 1900" do
    @education.end_year = 1899
    assert_not @education.valid?
    assert_includes @education.errors[:end_year], "must be greater than 1900"
  end

  test "should validate end_year is less than or equal to 2100" do
    @education.end_year = 2101
    assert_not @education.valid?
    assert_includes @education.errors[:end_year], "must be less than or equal to 2100"
  end

  test "should validate end_year is after or equal to start_year" do
    @education.start_year = 2020
    @education.end_year = 2019
    assert_not @education.valid?
    assert_includes @education.errors[:end_year], "must be greater than or equal to start year"
  end

  test "should allow end_year equal to start_year" do
    @education.start_year = 2020
    @education.end_year = 2020
    assert @education.valid?
  end

  # Enum Tests
  test "should accept valid degree_status values" do
    %w[graduated incomplete now_attending].each do |status|
      @education.degree_status = status
      assert @education.valid?, "#{status} should be valid"
    end
  end

  # Association Tests
  test "should belong to user" do
    assert_respond_to @education, :user
    assert_equal @user, @education.user
  end

  # Auto-assign Tests
  test "should auto-assign to first user on create when user not set" do
    edu = Education.new(
      school_name: "Test University",
      degree: "BS",
      field_of_study: "Engineering",
      start_year: 2020,
      end_year: 2024
    )
    edu.save
    assert_equal User.first, edu.user
  end

  test "should set default degree_status to now_attending if blank" do
    edu = Education.new(
      school_name: "Test University",
      degree: "BS",
      field_of_study: "Engineering",
      start_year: 2020,
      end_year: 2024
    )
    edu.save
    assert_equal "now_attending", edu.degree_status
  end

  # Class Method Tests
  test "should provide degree_status_enum for rails_admin" do
    enum_values = Education.degree_status_enum
    assert_includes enum_values, ["Graduated", "graduated"]
    assert_includes enum_values, ["Incomplete", "incomplete"]
    assert_includes enum_values, ["Now Attending", "now_attending"]
  end

  # Edge Cases
  test "should validate start_year as integer" do
    @education.start_year = 2020.5
    assert_not @education.valid?
    assert_includes @education.errors[:start_year], "must be an integer"
  end

  test "should validate end_year as integer" do
    @education.end_year = 2024.5
    assert_not @education.valid?
    assert_includes @education.errors[:end_year], "must be an integer"
  end

  test "end_year_after_start_year should not validate if start_year missing" do
    @education.start_year = nil
    @education.end_year = 2024
    # Should not add error for end_year_after_start_year since start_year is nil
    @education.valid?
    assert_not_includes @education.errors[:end_year], "must be greater than or equal to start year"
  end

  test "end_year_after_start_year should not validate if end_year missing" do
    @education.start_year = 2020
    @education.end_year = nil
    @education.degree_status = 'graduated'
    # Should not add error for end_year_after_start_year since end_year is nil
    @education.valid?
    assert_not_includes @education.errors[:end_year], "must be greater than or equal to start year"
  end

  # Edge Cases
  test "set_default_user should not override existing user" do
    edu = Education.new(
      school_name: "Test",
      degree: "BS",
      field_of_study: "Test",
      start_year: 2020,
      end_year: 2024,
      user: @user
    )
    edu.valid?
    assert_equal @user, edu.user
  end

  test "set_default_user should set user when nil" do
    edu = Education.new(
      school_name: "Test",
      degree: "BS",
      field_of_study: "Test",
      start_year: 2020,
      end_year: 2024,
      user: nil
    )
    edu.valid?
    assert_equal User.first, edu.user
  end

  test "set_default_degree_status should set to now_attending when blank" do
    edu = Education.new(
      school_name: "Test",
      degree: "BS",
      field_of_study: "Test",
      start_year: 2020,
      degree_status: nil
    )
    # end_year not required for now_attending
    edu.valid?
    assert_equal "now_attending", edu.degree_status
  end

  test "set_default_degree_status should not override existing status" do
    edu = Education.new(
      school_name: "Test",
      degree: "BS",
      field_of_study: "Test",
      start_year: 2020,
      end_year: 2024,
      degree_status: "graduated"
    )
    edu.valid?
    assert_equal "graduated", edu.degree_status
  end

  test "end_year_after_start_year should return early if start_year missing" do
    @education.start_year = nil
    @education.end_year = 2024
    @education.valid?
    assert_not_includes @education.errors[:end_year], "must be greater than or equal to start year"
  end

  test "end_year_after_start_year should return early if end_year missing" do
    @education.start_year = 2020
    @education.end_year = nil
    @education.degree_status = 'graduated'
    @education.valid?
    assert_not_includes @education.errors[:end_year], "must be greater than or equal to start year"
  end

  test "should have one attached certificate" do
    assert_respond_to @education, :certificate
  end
end
