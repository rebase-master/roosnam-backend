RailsAdmin.config do |config|
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  # Limit access to admins only
  config.authorize_with do
    redirect_to main_app.root_path unless current_user&.respond_to?(:admin?) && current_user.admin?
  end

  # Single-user mode: restrict User model actions
  config.model 'User' do
    # Only allow editing the existing user; prevent creation/deletion
    list do
      exclude_fields :encrypted_password, :reset_password_token
    end

    edit do
      exclude_fields :admin, :encrypted_password, :reset_password_token
    end
  end

  # Hide user_id field in forms for all models with user association
  # and auto-assign to current_user
  config.model 'CompanyExperience' do
    object_label_method :custom_label

    edit do
      exclude_fields :user
    end

    create do
      field :company
      field :company_text
      field :title
      field :start_date
      field :end_date
      field :description
      field :experience_letter
      field :relieving_letter
    end
  end

  config.model 'Certification' do
    edit do
      exclude_fields :user
    end

    create do
      field :title
      field :issuer
      field :issue_date
      field :expiration_date
      field :credential_url
    end
  end

  config.model 'Education' do
    edit do
      exclude_fields :user
    end

    create do
      field :institution
      field :degree
      field :field_of_study
      field :start_year
      field :end_year
      field :grade
      field :description
    end
  end
end


