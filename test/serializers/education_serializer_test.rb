require "test_helper"

class EducationSerializerTest < ActiveSupport::TestCase
  def setup
    @education = education(:bachelor)
    @serializer = EducationSerializer.new(@education)
    @serialization = @serializer.serializable_hash
  end

  test "should include all required attributes" do
    expected_keys = %i[
      id user_id school_name degree degree_status
      field_of_study start_year end_year certificate_url
    ]

    expected_keys.each do |key|
      assert @serialization.key?(key), "Missing attribute: #{key}"
    end
  end

  test "should return nil for certificate_url when not attached" do
    @education.certificate.purge if @education.certificate.attached?
    serializer = EducationSerializer.new(@education)
    serialization = serializer.serializable_hash

    assert_nil serialization[:certificate_url]
  end

  test "should include all education attributes" do
    assert_equal @education.id, @serialization[:id]
    assert_equal @education.school_name, @serialization[:school_name]
    assert_equal @education.degree, @serialization[:degree]
  end
end
