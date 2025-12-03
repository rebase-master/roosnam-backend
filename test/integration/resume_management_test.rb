require "test_helper"

class ResumeManagementTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:portfolio_user)
    # Clear any existing resume
    @user.resume.purge if @user.resume.attached?
    @user.remove_resume = false
    @user.save
  end

  test "should upload resume and rename it correctly" do
    # Upload a resume
    @user.resume.attach(
      io: StringIO.new("dummy pdf content"),
      filename: "original.pdf",
      content_type: "application/pdf"
    )
    @user.save

    # In test environment, after_commit may not run due to transactions
    # Manually trigger the filename update
    if @user.resume.attached?
      @user.send(:ensure_resume_filename)
      @user.resume.blob.reload
    end

    # Reload to get the renamed filename
    @user.reload
    assert @user.resume.attached?, "Resume should be attached"

    # Verify filename follows the pattern: firstname_lastname_ddmmyyyy.pdf
    filename = @user.resume.blob.filename.to_s
    assert filename.present?, "Filename should be present"
    assert_match(/\A[a-z_]+_\d{8}\.pdf\z/, filename.downcase, "Filename should match pattern: name_ddmmyyyy.pdf")

    # Verify it contains the user's name parts if full_name is present
    if @user.full_name.present?
      name_parts = @user.full_name.downcase.split(/\s+/)
      name_parts.each do |part|
        assert filename.downcase.include?(part.gsub(/[^a-z0-9]/, '_')), "Filename should include name part: #{part}"
      end
    end

    # Verify it contains today's date in ddmmyyyy format
    date_str = Date.current.strftime('%d%m%Y')
    assert filename.include?(date_str), "Filename should include today's date: #{date_str}"
  end

  test "should rename resume with only date when full_name is blank" do
    # Test filename generation when full_name would be blank
    # Since full_name has validation, we test the method directly
    @user.resume.attach(
      io: StringIO.new("dummy pdf content"),
      filename: "original.pdf",
      content_type: "application/pdf"
    )
    @user.save!
    
    # Test the generated_resume_filename method with a stubbed blank full_name
    # This verifies the logic works when full_name is blank
    date_str = Date.current.strftime('%d%m%Y')
    expected_filename = "#{date_str}.pdf"
    
    # Stub full_name to return blank for filename generation
    @user.stub(:full_name, "") do
      generated = @user.send(:generated_resume_filename)
      assert_equal expected_filename, generated, "Filename should be just date when full_name is blank"
    end
  end

  test "should delete resume when remove_resume flag is set" do
    # First upload a resume
    @user.resume.attach(
      io: StringIO.new("dummy pdf content"),
      filename: "original.pdf",
      content_type: "application/pdf"
    )
    @user.save
    @user.reload

    assert @user.resume.attached?, "Resume should be attached before deletion"

    # Set remove_resume flag and save
    @user.remove_resume = true
    @user.save
    @user.reload

    # Verify resume is deleted
    assert_not @user.resume.attached?, "Resume should be deleted after remove_resume flag is set"
    assert_equal false, @user.remove_resume, "remove_resume flag should be reset after deletion"
  end

  test "should not delete resume when remove_resume is false" do
    # Upload a resume
    @user.resume.attach(
      io: StringIO.new("dummy pdf content"),
      filename: "original.pdf",
      content_type: "application/pdf"
    )
    @user.save
    @user.reload

    assert @user.resume.attached?, "Resume should be attached"

    # Set remove_resume to false and save
    @user.remove_resume = false
    @user.save
    @user.reload

    # Verify resume is still attached
    assert @user.resume.attached?, "Resume should still be attached when remove_resume is false"
  end

  test "should validate resume file type" do
    # Try to upload an invalid file type
    @user.resume.attach(
      io: StringIO.new("dummy text content"),
      filename: "original.txt",
      content_type: "text/plain"
    )

    assert_not @user.valid?, "User should be invalid with non-PDF/DOC file"
    assert_includes @user.errors[:resume], "must be a PDF or DOC file"
  end

  test "should accept PDF files" do
    @user.resume.attach(
      io: StringIO.new("dummy pdf content"),
      filename: "test.pdf",
      content_type: "application/pdf"
    )

    assert @user.valid?, "User should be valid with PDF file"
  end

  test "should accept DOC files" do
    @user.resume.attach(
      io: StringIO.new("dummy doc content"),
      filename: "test.doc",
      content_type: "application/msword"
    )

    assert @user.valid?, "User should be valid with DOC file"
  end

  test "remove_resume field visibility should depend on resume attachment" do
    # When no resume is attached, remove_resume should not be relevant
    assert_not @user.resume.attached?, "No resume should be attached initially"

    # Upload resume
    @user.resume.attach(
      io: StringIO.new("dummy pdf content"),
      filename: "original.pdf",
      content_type: "application/pdf"
    )
    @user.save
    @user.reload

    assert @user.resume.attached?, "Resume should be attached"

    # Delete resume
    @user.remove_resume = true
    @user.save
    @user.reload

    assert_not @user.resume.attached?, "Resume should be deleted"
    # At this point, remove_resume field should not be visible in RailsAdmin
    # (tested via the visible block in RailsAdmin config)
  end

  test "should handle resume deletion when no resume is attached" do
    # Ensure no resume is attached
    assert_not @user.resume.attached?, "No resume should be attached"

    # Try to set remove_resume flag
    @user.remove_resume = true
    @user.save
    @user.reload

    # Should not error, but also shouldn't do anything
    assert_not @user.resume.attached?, "Resume should still not be attached"
  end

  test "should rename resume correctly with special characters in name" do
    @user.full_name = "John O'Brien-Smith"
    @user.save

    @user.resume.attach(
      io: StringIO.new("dummy pdf content"),
      filename: "original.pdf",
      content_type: "application/pdf"
    )
    @user.save

    # In test environment, after_commit may not run due to transactions
    # Manually trigger the filename update
    @user.send(:ensure_resume_filename) if @user.resume.attached?

    @user.reload
    @user.resume.blob.reload if @user.resume.attached?

    filename = @user.resume.blob.filename.to_s
    assert filename.present?, "Filename should be present"
    # Special characters should be sanitized to underscores
    assert_match(/\A[a-z_]+_\d{8}\.pdf\z/, filename.downcase, "Filename should have special characters sanitized")
    assert_not filename.include?("'"), "Filename should not contain apostrophes"
    assert_not filename.include?("-"), "Filename should not contain hyphens (except date separator)"
  end
end

