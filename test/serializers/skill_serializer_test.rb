require "test_helper"

class SkillSerializerTest < ActiveSupport::TestCase
  def setup
    @skill = skills(:ruby)
    @serializer = SkillSerializer.new(@skill)
    @serialization = @serializer.serializable_hash
  end

  test "should include all required attributes" do
    expected_keys = %i[
      id name slug proficiency_level years_of_experience source_company
    ]

    expected_keys.each do |key|
      assert @serialization.key?(key), "Missing attribute: #{key}"
    end
  end

  test "should return source_company from work_experience when present" do
    assert @serialization.key?(:source_company)
    if @skill.work_experience
      assert_equal @skill.work_experience.employer_name, @serialization[:source_company]
    end
  end

  test "should handle skill without work_experience" do
    skill = Skill.create!(
      name: "Independent Skill",
      proficiency_level: "expert",
      years_of_experience: 5
    )
    serializer = SkillSerializer.new(skill)
    serialization = serializer.serializable_hash

    # Should not raise error
    assert serialization.key?(:source_company)
  end
end
