require "test_helper"

class CertificationTest < ActiveSupport::TestCase
  def setup
    @certification = certifications(:aws_cert)
    @user = users(:portfolio_user)
  end

  # Validation Tests
  test "should be valid with valid attributes" do
    assert @certification.valid?
  end

  test "should require title" do
    @certification.title = nil
    assert_not @certification.valid?
    assert_includes @certification.errors[:title], "can't be blank"
  end

  test "should require issuer" do
    @certification.issuer = nil
    assert_not @certification.valid?
    assert_includes @certification.errors[:issuer], "can't be blank"
  end

  # Association Tests
  test "should belong to user" do
    assert_respond_to @certification, :user
    assert_equal @user, @certification.user
  end

  # Auto-assign User Tests
  test "should auto-assign to first user on create when user not set" do
    cert = Certification.new(
      title: "New Certification",
      issuer: "Test Issuer"
    )
    cert.save
    assert_equal User.first, cert.user
  end

  test "should not override user if already set" do
    new_cert = Certification.create(
      title: "Test Cert",
      issuer: "Test Issuer",
      user: @user
    )
    assert_equal @user, new_cert.user
  end

  # Date Tests
  test "should allow nil expiration_date" do
    @certification.expiration_date = nil
    assert @certification.valid?
  end

  test "should allow valid dates" do
    @certification.issue_date = Date.today - 1.year
    @certification.expiration_date = Date.today + 1.year
    assert @certification.valid?
  end
end
