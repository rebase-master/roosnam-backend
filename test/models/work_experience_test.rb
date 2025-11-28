require "test_helper"

class WorkExperienceTest < ActiveSupport::TestCase
  setup do
    @user = create_portfolio_user
  end

  test "requires employer_name" do
    exp = WorkExperience.new(job_title: "Dev", start_date: Date.today)
    assert_not exp.valid?
    assert_includes exp.errors[:employer_name], "can't be blank"
  end

  test "requires job_title" do
    exp = WorkExperience.new(employer_name: "Company", start_date: Date.today)
    assert_not exp.valid?
    assert_includes exp.errors[:job_title], "can't be blank"
  end

  test "requires start_date" do
    exp = WorkExperience.new(employer_name: "Company", job_title: "Dev")
    assert_not exp.valid?
    assert_includes exp.errors[:start_date], "can't be blank"
  end

  test "end_date must be after start_date" do
    exp = WorkExperience.new(
      employer_name: "Company",
      job_title: "Dev",
      start_date: Date.today,
      end_date: 1.month.ago
    )
    assert_not exp.valid?
    assert_includes exp.errors[:end_date], "must be after start date"
  end

  test "auto-assigns singleton user" do
    exp = WorkExperience.create!(
      employer_name: "Auto Company",
      job_title: "Dev",
      start_date: Date.today
    )
    assert_equal @user, exp.user
  end

  test "current? returns true when end_date is nil" do
    exp = @user.work_experiences.create!(
      employer_name: "Company",
      job_title: "Dev",
      start_date: Date.today
    )
    assert exp.current?
  end

  test "duration_in_months calculates correctly" do
    exp = @user.work_experiences.create!(
      employer_name: "Company",
      job_title: "Dev",
      start_date: 2.years.ago,
      end_date: Date.today
    )
    assert_in_delta 24, exp.duration_in_months, 1
  end
end
