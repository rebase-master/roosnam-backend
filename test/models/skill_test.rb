require "test_helper"

class SkillTest < ActiveSupport::TestCase
  setup do
    @user = create_portfolio_user
    @experience = @user.work_experiences.create!(
      employer_name: "Tech Corp",
      job_title: "Developer",
      start_date: 1.year.ago
    )
  end

  test "requires name" do
    skill = Skill.new(work_experience: @experience)
    assert_not skill.valid?
    assert_includes skill.errors[:name], "can't be blank"
  end

  test "generates unique slug from name" do
    skill1 = Skill.create!(name: "Ruby on Rails", work_experience: @experience)
    assert_equal "ruby-on-rails", skill1.slug

    skill2 = Skill.create!(name: "Ruby on Rails", work_experience: @experience)
    assert_equal "ruby-on-rails-1", skill2.slug
  end

  test "validates proficiency_level inclusion" do
    skill = Skill.new(
      name: "Test",
      work_experience: @experience,
      proficiency_level: "invalid"
    )
    assert_not skill.valid?
    assert_includes skill.errors[:proficiency_level], "is not included in the list"
  end

  test "validates years_of_experience range" do
    skill = Skill.new(
      name: "Test",
      work_experience: @experience,
      years_of_experience: 150
    )
    assert_not skill.valid?
  end

  test "accepts valid proficiency levels" do
    %w[beginner intermediate advanced expert].each do |level|
      skill = Skill.new(
        name: "Skill #{level}",
        work_experience: @experience,
        proficiency_level: level
      )
      assert skill.valid?, "Expected #{level} to be valid"
    end
  end
end
