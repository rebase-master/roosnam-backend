RailsAdmin.config do |config|
  config.asset_source = :sprockets
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  # Limit access to admins only
  config.authorize_with do
    redirect_to main_app.root_path unless current_user&.respond_to?(:admin?) && current_user.admin?
  end

  # Configure actions - disable create and delete for User model (singleton pattern)
  config.actions do
    dashboard
    index
    new do
      except ['User']  # Disable new/create for User model
    end
    export
    bulk_delete
    show
    edit
    delete do
      except ['User']  # Disable delete for User model
    end
    show_in_app
  end

  # Add custom navigation item for Portfolio Owner (singleton user)
  # This creates a static link that goes directly to edit page
  # Since it's a singleton, the user ID will always be 1
  config.navigation_static_label = 'Portfolio'
  config.navigation_static_links = {
    'Portfolio Owner' => '/admin/user/1/edit'
  }

  # Single-user mode: restrict User model actions
  config.model 'User' do
    # Customize labels for singleton user
    navigation_label 'Portfolio'
    label 'Portfolio Owner'
    label_plural 'Portfolio Owner'
    
    # Hide from main navigation menu (correct syntax per RailsAdmin docs)
    visible false

    # Customize list view - limit to 1 item
    list do
      # Limit to 1 item and disable pagination
      items_per_page 1
      sort_by :id
      
      # Hide fields we don't need
      exclude_fields :encrypted_password, :reset_password_token, :remember_created_at,
                     :reset_password_token, :social_links, :portfolio_settings
      
      # Show only essential fields  
      fields :id, :email, :full_name, :display_name, :admin, :created_at, :updated_at
    end

    # Customize show view (details page)
    show do
      # Hide admin field and associations
      exclude_fields :admin, :encrypted_password, :reset_password_token, :remember_created_at,
                     :work_experiences, :education, :certifications, :client_projects, 
                     :client_reviews, :attachments
      
      # Format availability_status in title case
      field :availability_status do
        formatted_value do
          value.present? ? value.humanize : ''
        end
      end
      
      # Show blank if social_links is empty
      field :social_links do
        formatted_value do
          if value.present? && value.is_a?(Hash) && value.any?
            value.to_json
          else
            ''
          end
        end
      end
      
      # Display portfolio_settings in a more presentable manner
      field :portfolio_settings do
        formatted_value do
          if value.present? && value.is_a?(Hash)
            settings = value.map { |k, v| "#{k.to_s.humanize}: #{v}" }.join('<br>')
            settings.html_safe
          else
            ''
          end
        end
      end
      
      # Display profile_completeness as percentage
      field :profile_completeness do
        formatted_value do
          "#{value || 0}%"
        end
      end
    end

    # Only allow editing
    edit do
      exclude_fields :admin, :encrypted_password, :reset_password_token, :remember_created_at,
                     :reset_password_sent_at, :work_experiences, :education, 
                     :certifications, :attachments

      group :personal do
        label 'Personal Information'
        field :full_name
        field :display_name do
          help 'Optional: If empty, full_name will be used'
        end
        field :email
        field :phone
        field :location do
          help 'Format: "City, Country"'
        end
        field :timezone
      end

      group :professional do
        label 'Professional Information'
        field :headline do
          help 'e.g., "Senior Full Stack Developer"'
        end
        field :bio, :text do
          help 'Your detailed biography/about section'
        end
        field :tagline do
          help 'Short catchy phrase'
        end
        field :years_of_experience
        field :availability_status, :enum do
          enum ['available', 'open_to_opportunities', 'not_available']
          help 'Your current availability for work'
        end
        field :hourly_rate do
          help 'Format: "USD 75/hr" or "€60/hr"'
        end
      end

      group :social do
        label 'Social Links'
        field :social_links, :json do
          help 'JSON format: {"linkedin": "url", "github": "url", "twitter": "url", ...}'
        end
      end

      group :seo do
        label 'SEO Settings'
        field :seo_title do
          help 'Custom page title for search engines'
        end
        field :seo_description, :text do
          help 'Meta description for search engines'
        end
      end

      group :settings do
        label 'Portfolio Settings'
        field :portfolio_settings, :json do
          help 'JSON format: {"show_email": true, "show_phone": false, "theme_preference": "light"}'
        end
      end

      group :metadata do
        label 'Metadata'
        field :profile_completeness do
          read_only true
          help 'Calculated automatically based on filled fields'
        end
      end
    end
  end

  # WorkExperience configuration
  config.model 'WorkExperience' do
    object_label_method :custom_label
    navigation_label 'Portfolio'

    list do
      fields :id, :employer_name, :job_title, :start_date, :end_date, :city, :state, :country, :created_at
    end

    show do
      exclude_fields :user
    end

    edit do
      exclude_fields :user
      field :employer_name do
        required true
      end
      field :job_title
      field :start_date do
        required true
      end
      field :end_date do
        help 'Leave blank if currently working here'
      end
      field :city
      field :state
      field :country
    end

    create do
      exclude_fields :user, :skills, :client_projects, :city, :state, :country, :end_date

      field :employer_name do
        required true
      end
      field :job_title
      field :start_date do
        required true
      end
      field :end_date do
        help 'Leave blank if currently working here (optional)'
      end
      field :city
      field :state
      field :country
    end
  end

  # Skill configuration
  config.model 'Skill' do
    navigation_label 'Portfolio'

    list do
      fields :id, :name, :proficiency_level, :years_of_experience, :slug, :work_experience_id, :created_at
    end

    show do
      field :work_experience
    end

    edit do
      group :basic do
        label 'Basic Information'
        field :name do
          required true
        end
        field :slug do
          read_only true
          help 'Automatically generated from name'
        end
        field :proficiency_level, :enum do
          enum ['beginner', 'intermediate', 'advanced', 'expert']
        end
        field :years_of_experience do
          help 'Years of experience with this skill (e.g., 2.5)'
        end
        field :work_experience_id do
          help 'Optional: Associate with a specific work experience'
        end
      end
    end

    create do
      group :basic do
        label 'Basic Information'
        field :name do
          required true
        end
        field :proficiency_level, :enum do
          enum ['beginner', 'intermediate', 'advanced', 'expert']
        end
        field :years_of_experience do
          help 'Years of experience with this skill (e.g., 2.5)'
        end
        field :work_experience_id do
          help 'Optional: Associate with a specific work experience'
        end
      end
    end
  end

  # ClientProject configuration
  config.model 'ClientProject' do
    navigation_label 'Portfolio'

    list do
      fields :id, :name, :client_name, :role, :start_date, :end_date, :created_at
    end

    show do
      exclude_fields :user
    end

    edit do
      exclude_fields :user

      group :basic do
        label 'Project Information'
        field :name do
          required true
        end
        field :description, :text do
          required true
        end
        field :role
        field :project_url do
          help 'URL to the project (if publicly available)'
        end
      end

      group :client do
        label 'Client Information'
        field :client_name
        field :client_website
      end

      group :details do
        label 'Project Details'
        field :tech_stack do
          help 'Comma-separated list of technologies used'
        end
        field :start_date
        field :end_date do
          help 'Leave blank if project is ongoing'
        end
      end

      group :associations do
        label 'Associations'
        field :client_reviews do
          read_only true
        end
      end
    end

    create do
      exclude_fields :user

      group :basic do
        label 'Project Information'
        field :name do
          required true
        end
        field :description, :text do
          required true
        end
        field :role
        field :project_url do
          help 'URL to the project (if publicly available)'
        end
      end

      group :client do
        label 'Client Information'
        field :client_name
        field :client_website
      end

      group :details do
        label 'Project Details'
        field :tech_stack do
          help 'Comma-separated list of technologies used'
        end
        field :start_date
        field :end_date do
          help 'Leave blank if project is ongoing'
        end
      end

      group :associations do
        label 'Associations'
        field :client_reviews do
          read_only true
        end
      end
    end
  end

  # ClientReview configuration
  config.model 'ClientReview' do
    navigation_label 'Portfolio'

    list do
      fields :id, :reviewer_name, :reviewer_company, :rating, :client_project, :created_at
    end

    show do
      exclude_fields :user, :client_project_id
    end

    edit do
      exclude_fields :user

      group :review do
        label 'Review Content'
        field :review_text, :text do
          required true
        end
        field :rating do
          help 'Rating from 1 to 5'
        end
      end

      group :reviewer do
        label 'Reviewer Information'
        field :reviewer_name
        field :reviewer_position
        field :reviewer_company
      end

      group :associations do
        label 'Associations'
        field :client_project do
          required true
        end
      end
    end

    create do
      exclude_fields :user

      group :review do
        label 'Review Content'
        field :review_text, :text do
          required true
        end
        field :rating do
          help 'Rating from 1 to 5'
        end
      end

      group :reviewer do
        label 'Reviewer Information'
        field :reviewer_name
        field :reviewer_position
        field :reviewer_company
      end

      group :associations do
        label 'Associations'
        field :client_project do
          required true
        end
      end
    end
  end

  # Certification configuration
  config.model 'Certification' do
    navigation_label 'Portfolio'

    edit do
      exclude_fields :user

      group :basic do
        label 'Certification Information'
        field :title do
          required true
        end
        field :issuer do
          required true
        end
        field :credential_url do
          help 'URL to verify the credential'
        end
      end

      group :dates do
        label 'Dates'
        field :issue_date
        field :expiration_date do
          help 'Leave blank if certification does not expire'
        end
      end

      group :attachments do
        label 'Attachments'
        field :document do
          help 'Upload certification document'
        end
      end
    end

    create do
      exclude_fields :user

      group :basic do
        label 'Certification Information'
        field :title do
          required true
        end
        field :issuer do
          required true
        end
        field :credential_url do
          help 'URL to verify the credential'
        end
      end

      group :dates do
        label 'Dates'
        field :issue_date
        field :expiration_date do
          help 'Leave blank if certification does not expire'
        end
      end

      group :attachments do
        label 'Attachments'
        field :document do
          help 'Upload certification document'
        end
      end
    end
  end

  # Education configuration
  config.model 'Education' do
    navigation_label 'Portfolio'

    edit do
      exclude_fields :user

      group :basic do
        label 'Education Information'
        field :institution do
          required true
        end
        field :degree do
          required true
        end
        field :field_of_study
        field :grade
        field :description, :text
      end

      group :dates do
        label 'Dates'
        field :start_year
        field :end_year do
          help 'Leave blank if currently studying'
        end
      end

      group :attachments do
        label 'Attachments'
        field :certificate do
          help 'Upload degree/certificate document'
        end
      end
    end

    create do
      exclude_fields :user

      group :basic do
        label 'Education Information'
        field :institution do
          required true
        end
        field :degree do
          required true
        end
        field :field_of_study
        field :grade
        field :description, :text
      end

      group :dates do
        label 'Dates'
        field :start_year
        field :end_year do
          help 'Leave blank if currently studying'
        end
      end

      group :attachments do
        label 'Attachments'
        field :certificate do
          help 'Upload degree/certificate document'
        end
      end
    end
  end
end


