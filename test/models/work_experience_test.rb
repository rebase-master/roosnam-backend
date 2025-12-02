require "test_helper"

class WorkExperienceTest < ActiveSupport::TestCase
  def setup
    @work_experience = work_experiences(:current_job)
    @user = users(:portfolio_user)
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    assert @work_experience.valid?
  end

  test "should require job_title" do
    @work_experience.job_title = nil
    assert_not @work_experience.valid?
    assert_includes @work_experience.errors[:job_title], "can't be blank"
  end

  test "should require start_date" do
    @work_experience.start_date = nil
    assert_not @work_experience.valid?
    assert_includes @work_experience.errors[:start_date], "can't be blank"
  end

  test "should require employer_name" do
    @work_experience.employer_name = nil
    assert_not @work_experience.valid?
    assert_includes @work_experience.errors[:employer_name], "can't be blank"
  end

  test "should allow nil end_date for current positions" do
    @work_experience.end_date = nil
    assert @work_experience.valid?
  end

  # Association Tests
  test "should belong to user" do
    assert_respond_to @work_experience, :user
    assert_equal @user, @work_experience.user
  end

  test "should have many skills" do
    assert_respond_to @work_experience, :skills
    assert @work_experience.skills.count >= 0
  end

  # Note: client_projects association is commented out in model due to missing FK
  # test "should have many client_projects" do
  #   assert_respond_to @work_experience, :client_projects
  # end

  # Auto-assign Tests
  test "should auto-assign to first user on create when user not set" do
    work_exp = WorkExperience.new(
      job_title: "Software Engineer",
      employer_name: "Test Company",
      start_date: Date.today - 1.year
    )
    work_exp.save
    assert_equal User.first, work_exp.user
  end

  # Custom Label Tests
  test "custom_label should return job_title and employer_name" do
    expected = "Senior Full Stack Developer at Tech Corp Inc"
    assert_equal expected, @work_experience.custom_label
  end

  test "custom_label should handle unknown company" do
    @work_experience.employer_name = nil
    expected = "Senior Full Stack Developer at Unknown Company"
    assert_equal expected, @work_experience.custom_label
  end

  # Duration Tests
  test "duration_in_months should calculate months for ended position" do
    @work_experience.start_date = Date.new(2020, 1, 1)
    @work_experience.end_date = Date.new(2021, 1, 1)
    assert_equal 12, @work_experience.duration_in_months
  end

  test "duration_in_months should use current date for ongoing position" do
    @work_experience.start_date = Date.today - 6.months
    @work_experience.end_date = nil
    duration = @work_experience.duration_in_months
    assert duration >= 6, "Duration should be at least 6 months"
    assert duration <= 7, "Duration should be at most 7 months (accounting for partial months)"
  end

  test "duration_in_months should handle same month start and end" do
    @work_experience.start_date = Date.new(2020, 5, 1)
    @work_experience.end_date = Date.new(2020, 5, 31)
    assert_equal 0, @work_experience.duration_in_months
  end

  test "duration_in_months should handle cross-year periods" do
    @work_experience.start_date = Date.new(2020, 11, 1)
    @work_experience.end_date = Date.new(2021, 2, 1)
    assert_equal 3, @work_experience.duration_in_months
  end

  test "custom_label should handle nil job_title gracefully" do
    @work_experience.job_title = nil
    @work_experience.employer_name = "Test Company"
    # Should not raise error
    label = @work_experience.custom_label
    assert label.is_a?(String)
  end

  # Dependent Nullify Tests
  test "should nullify skills when work experience is destroyed" do
    skill = skills(:ruby)
    skill.update(work_experience: @work_experience)
    @work_experience.destroy
    skill.reload
    assert_nil skill.work_experience_id
  end

  # Edge Cases
  test "set_default_user should not override existing user" do
    work_exp = WorkExperience.new(
      job_title: "Test",
      employer_name: "Company",
      start_date: Date.today,
      user: @user
    )
    work_exp.valid?
    assert_equal @user, work_exp.user
  end

  test "set_default_user should set user when nil" do
    work_exp = WorkExperience.new(
      job_title: "Test",
      employer_name: "Company",
      start_date: Date.today,
      user: nil
    )
    work_exp.valid?
    assert_equal User.first, work_exp.user
  end

  test "custom_label should handle nil job_title" do
    @work_experience.job_title = nil
    label = @work_experience.custom_label
    assert label.is_a?(String)
    assert label.include?(@work_experience.employer_name || 'Unknown Company')
  end

  test "duration_in_months should handle leap year correctly" do
    @work_experience.start_date = Date.new(2020, 2, 1)
    @work_experience.end_date = Date.new(2021, 2, 1)
    assert_equal 12, @work_experience.duration_in_months
  end

  test "duration_in_months should handle year boundary correctly" do
    @work_experience.start_date = Date.new(2020, 12, 1)
    @work_experience.end_date = Date.new(2021, 1, 1)
    assert_equal 1, @work_experience.duration_in_months
  end
end
