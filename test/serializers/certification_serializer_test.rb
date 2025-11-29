require "test_helper"

class CertificationSerializerTest < ActiveSupport::TestCase
  def setup
    @certification = certifications(:aws_cert)
    @serializer = CertificationSerializer.new(@certification)
    @serialization = @serializer.serializable_hash
  end

  test "should include all required attributes" do
    expected_keys = %i[
      id user_id title issuer issue_date expiration_date
      credential_url document_url is_expired
    ]

    expected_keys.each do |key|
      assert @serialization.key?(key), "Missing attribute: #{key}"
    end
  end

  test "should return false for is_expired when no expiration_date" do
    @certification.expiration_date = nil
    serializer = CertificationSerializer.new(@certification)
    serialization = serializer.serializable_hash

    assert_equal false, serialization[:is_expired]
  end

  test "should return true for is_expired when expiration_date is past" do
    @certification.expiration_date = Date.today - 1.day
    serializer = CertificationSerializer.new(@certification)
    serialization = serializer.serializable_hash

    assert_equal true, serialization[:is_expired]
  end

  test "should return false for is_expired when expiration_date is future" do
    @certification.expiration_date = Date.today + 1.year
    serializer = CertificationSerializer.new(@certification)
    serialization = serializer.serializable_hash

    assert_equal false, serialization[:is_expired]
  end

  test "should return nil for document_url when not attached" do
    @certification.document.purge if @certification.document.attached?
    serializer = CertificationSerializer.new(@certification)
    serialization = serializer.serializable_hash

    assert_nil serialization[:document_url]
  end
end
