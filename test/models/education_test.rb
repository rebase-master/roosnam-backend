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

  test "should require end_year" do
    @education.end_year = nil
    assert_not @education.valid?
    assert_includes @education.errors[:end_year], "can't be blank"
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
end
