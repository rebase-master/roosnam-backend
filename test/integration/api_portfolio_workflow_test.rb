require "test_helper"

class ApiPortfolioWorkflowTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:portfolio_user)
    # Clear rack-attack cache to avoid rate limiting between tests
    Rack::Attack.cache.store.clear
  end

  def teardown
    Rack::Attack.cache.store.clear
  end

  # Complete Portfolio Retrieval Workflow
  test "should retrieve complete portfolio data in sequence" do
    # Step 1: Get user profile
    get api_v1_profile_url, as: :json
    assert_response :success
    profile = JSON.parse(response.body)
    assert_equal @user.email, profile['email']
    assert_equal @user.full_name, profile['full_name']

    # Step 2: Get work experiences with skills
    get api_v1_work_experiences_url, as: :json
    assert_response :success
    experiences = JSON.parse(response.body)
    assert experiences.is_a?(Array)
    assert experiences.any? { |exp| exp['skills'].is_a?(Array) }

    # Step 3: Get all skills
    get api_v1_skills_url, as: :json
    assert_response :success
    skills = JSON.parse(response.body)
    assert skills.is_a?(Array)

    # Step 4: Get education
    get api_v1_education_index_url, as: :json
    assert_response :success
    education = JSON.parse(response.body)
    assert education.is_a?(Array)

    # Step 5: Get certifications
    get api_v1_certifications_url, as: :json
    assert_response :success
    certifications = JSON.parse(response.body)
    assert certifications.is_a?(Array)

    # Step 6: Get client projects with reviews
    get api_v1_client_projects_url, as: :json
    assert_response :success
    projects = JSON.parse(response.body)
    assert projects.is_a?(Array)

    # Verify projects include skills and reviews
    if projects.any?
      project = projects.first
      assert project.key?('skills')
      assert project.key?('client_reviews')
    end

    # Step 7: Get individual project details
    if projects.any?
      project_id = projects.first['id']
      get api_v1_client_project_url(id: project_id), as: :json
      assert_response :success
      project_detail = JSON.parse(response.body)
      assert_equal project_id, project_detail['id']
    end

    # Step 8: Get all client reviews
    get api_v1_client_reviews_url, as: :json
    assert_response :success
    reviews = JSON.parse(response.body)
    assert reviews.is_a?(Array)
  end

  # Portfolio Data Consistency Check
  test "should maintain data consistency across endpoints" do
    # Get profile
    get api_v1_profile_url, as: :json
    profile = JSON.parse(response.body)
    user_id = profile['id']

    # Verify all resources belong to the same user
    get api_v1_work_experiences_url, as: :json
    experiences = JSON.parse(response.body)
    experiences.each do |exp|
      assert_equal user_id, exp['user_id'], "Work experience should belong to portfolio user"
    end

    get api_v1_client_projects_url, as: :json
    projects = JSON.parse(response.body)
    projects.each do |project|
      assert_equal user_id, project['user_id'], "Client project should belong to portfolio user"
    end
  end

  # Profile Completeness Workflow
  test "should calculate and return profile completeness" do
    get api_v1_profile_url, as: :json
    assert_response :success

    profile = JSON.parse(response.body)
    assert profile.key?('profile_completeness')
    assert profile['profile_completeness'].is_a?(Integer)
    assert profile['profile_completeness'] >= 0
    assert profile['profile_completeness'] <= 100
  end

  # Skills from Multiple Sources
  test "should aggregate skills from work experiences" do
    # Get all skills
    get api_v1_skills_url, as: :json
    assert_response :success
    all_skills = JSON.parse(response.body)

    # Get work experiences
    get api_v1_work_experiences_url, as: :json
    experiences = JSON.parse(response.body)

    # Skills should be ordered by experience and name
    if all_skills.length > 1
      # Verify descending order by years_of_experience
      years = all_skills.map { |s| s['years_of_experience'] || 0 }
      assert years == years.sort.reverse ||
             all_skills.first['years_of_experience'] == all_skills.last['years_of_experience'],
             "Skills should be ordered by experience"
    end
  end

  # Client Project with Reviews Workflow
  test "should retrieve projects with associated reviews and skills" do
    get api_v1_client_projects_url, as: :json
    assert_response :success
    projects = JSON.parse(response.body)

    projects.each do |project|
      # Verify project has required associations
      assert project.key?('skills'), "Project should include skills"
      assert project.key?('client_reviews'), "Project should include client_reviews"
      assert project['skills'].is_a?(Array)
      assert project['client_reviews'].is_a?(Array)

      # Verify review structure if reviews exist
      if project['client_reviews'].any?
        review = project['client_reviews'].first
        assert review.key?('reviewer_name')
        assert review.key?('review_text')
        assert review.key?('reviewer_display_name')
      end
    end
  end

  # Current Experience Calculation
  test "should correctly identify and return current experience" do
    get api_v1_profile_url, as: :json
    assert_response :success

    profile = JSON.parse(response.body)

    # Should have current_role and current_company
    assert profile.key?('current_role')
    assert profile.key?('current_company')

    # Get work experiences to verify
    get api_v1_work_experiences_url, as: :json
    experiences = JSON.parse(response.body)

    current_experiences = experiences.select { |exp| exp['end_date'].nil? }
    if current_experiences.any?
      # Profile should match the most recent current experience
      most_recent = current_experiences.max_by { |exp| exp['start_date'] }
      assert_equal most_recent['job_title'], profile['current_role']
    end
  end

  # Education Timeline
  test "should return education in reverse chronological order" do
    get api_v1_education_index_url, as: :json
    assert_response :success

    education = JSON.parse(response.body)

    if education.length > 1
      # Verify descending order by end_year
      end_years = education.map { |e| e['end_year'] }
      assert end_years == end_years.sort.reverse,
             "Education should be ordered by end_year descending"
    end
  end

  # Certification Expiration Check
  test "should correctly indicate expired certifications" do
    get api_v1_certifications_url, as: :json
    assert_response :success

    certifications = JSON.parse(response.body)

    certifications.each do |cert|
      assert cert.key?('is_expired'), "Certification should have is_expired field"

      if cert['expiration_date']
        expiration = Date.parse(cert['expiration_date'])
        expected_expired = expiration < Date.current
        assert_equal expected_expired, cert['is_expired'],
                     "is_expired should match actual expiration status"
      else
        assert_equal false, cert['is_expired'],
                     "Certifications without expiration_date should not be expired"
      end
    end
  end

  # Privacy Settings Workflow
  test "should respect privacy settings for email and phone" do
    # When show_email is true (default)
    get api_v1_profile_url, as: :json
    profile = JSON.parse(response.body)

    # Email should be visible by default
    if @user.show_email?
      assert profile['email'].present?, "Email should be visible when show_email is true"
    else
      assert_nil profile['email'], "Email should be hidden when show_email is false"
    end

    # Phone visibility depends on show_phone setting
    if @user.show_phone?
      assert profile.key?('phone')
    end
  end

  # Complete Data Structure Validation
  test "should return properly structured JSON for all endpoints" do
    endpoints = [
      { url: api_v1_profile_url, type: :object },
      { url: api_v1_work_experiences_url, type: :array },
      { url: api_v1_skills_url, type: :array },
      { url: api_v1_education_index_url, type: :array },
      { url: api_v1_certifications_url, type: :array },
      { url: api_v1_client_projects_url, type: :array },
      { url: api_v1_client_reviews_url, type: :array }
    ]

    endpoints.each do |endpoint|
      get endpoint[:url], as: :json
      assert_response :success
      assert_equal 'application/json; charset=utf-8', response.content_type

      data = JSON.parse(response.body)

      case endpoint[:type]
      when :array
        assert data.is_a?(Array), "#{endpoint[:url]} should return an array"
      when :object
        assert data.is_a?(Hash), "#{endpoint[:url]} should return an object"
      end
    end
  end
end
