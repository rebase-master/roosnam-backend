require "test_helper"

class WorkExperienceSerializerTest < ActiveSupport::TestCase
  def setup
    @work_experience = work_experiences(:current_job)
    @serializer = WorkExperienceSerializer.new(@work_experience)
    @serialization = @serializer.serializable_hash
  end

  test "should include all required attributes" do
    expected_keys = %i[
      id user_id employer_name job_title start_date end_date
      city state country skills
    ]

    expected_keys.each do |key|
      assert @serialization.key?(key), "Missing attribute: #{key}"
    end
  end

  test "should serialize associated skills" do
    assert @serialization.key?(:skills)
    assert @serialization[:skills].is_a?(Array)
  end

  test "should include all work experience attributes" do
    assert_equal @work_experience.id, @serialization[:id]
    assert_equal @work_experience.job_title, @serialization[:job_title]
    assert_equal @work_experience.employer_name, @serialization[:employer_name]
  end
end
