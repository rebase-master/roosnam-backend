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

  # Re-authenticate user after updating their own record (prevents logout)
  config.parent_controller = 'ApplicationController'

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

    # Configure virtual attributes for social links and portfolio settings
    configure :linkedin_url, :string
    configure :github_url, :string
    configure :twitter_url, :string
    configure :website_url, :string
    configure :setting_show_email, :boolean
    configure :setting_show_phone, :boolean
    configure :setting_theme_preference, :enum do
      enum { ['light', 'dark'] }
    end

    # Customize list view - limit to 1 item
    list do
      # Limit to 1 item and disable pagination
      items_per_page 1
      sort_by :id
      
      # Hide fields we don't need
      exclude_fields :encrypted_password, :reset_password_token, :remember_created_at,
                     :reset_password_token, :social_links, :portfolio_settings
      
      # Show only essential fields  
      fields :id, :email, :full_name, :display_name, :availability_status, :admin, :created_at, :updated_at

      field :availability_status do
        pretty_value do
          bindings[:view].availability_badge(value)
        end
      end
    end

    # Customize show view (details page)
    show do
      # Hide admin field and associations
      exclude_fields :admin, :encrypted_password, :reset_password_token, :remember_created_at,
                     :work_experiences, :education, :certifications, :client_projects, 
                     :client_reviews, :attachments
      
      # Format availability_status in title case
      field :availability_status do
        pretty_value do
          bindings[:view].availability_badge(value)
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
                     :certifications, :attachments, :profile_completeness, :client_projects, :client_reviews,
                     :social_links, :portfolio_settings

      group :personal do
        label 'Personal Information'
        field :full_name
        field :display_name do
          help 'Optional: If empty, full name will be used'
        end
        field :profile_photo do
          help 'Upload your profile photo'
        end
        field :phone
        field :location do
          help 'Format: "City, Country"'
        end
        field :timezone
      end

      group :professional do
        label 'Professional Summary'
        field :headline do
          help 'e.g., "Senior Full Stack Developer"'
        end
        field :bio, :text do
          help 'Your detailed biography/about section'
        end
        field :tagline do
          help 'Short catchy phrase'
        end
      end

      group :resume_upload do
        label 'Resume / CV'
        field :resume, :active_storage do
          help 'Upload your resume/CV (PDF or DOC only). The file will be renamed automatically for public download.'

          pretty_value do
            if bindings[:object].resume.attached?
              bindings[:view].link_to(
                bindings[:object].resume.filename.to_s,
                Rails.application.routes.url_helpers.rails_blob_path(
                  bindings[:object].resume,
                  disposition: :attachment,
                  only_path: true
                ),
                target: '_blank',
                rel: 'noopener'
              )
            else
              'No resume uploaded'
            end
          end
        end

        field :remove_resume, :boolean do
          label 'Remove existing resume'
          help 'Check and save to delete the currently uploaded resume.'
          visible do
            bindings[:object].resume.attached?
          end
        end
      end

      group :work_details do
        label 'Work Details'
        field :years_of_experience do
          help 'Total years of professional experience'
        end
        field :hourly_rate do
          help 'Format: "USD 75/hr" or "€60/hr"'
        end
        field :availability_status, :enum do
          label 'Availability status'

          enum do
            [
              ['Available for work', 'available'],
              ['Open to opportunities', 'open_to_opportunities'],
              ['Not available', 'not_available']
            ]
          end

          pretty_value do
            case value
            when 'available' then 'Available for work'
            when 'open_to_opportunities' then 'Open to opportunities'
            when 'not_available' then 'Not available'
            else
              value.to_s.humanize
            end
          end

          help 'Your current availability for work'
        end
      end

      group :social do
        label 'Social Links'
        field :linkedin_url, :string do
          label 'LinkedIn URL'
          help 'Your LinkedIn profile URL'
          visible true
        end
        field :github_url, :string do
          label 'GitHub URL'
          help 'Your GitHub profile URL'
          visible true
        end
        field :twitter_url, :string do
          label 'Twitter/X URL'
          help 'Your Twitter/X profile URL'
          visible true
        end
        field :website_url, :string do
          label 'Website URL'
          help 'Your personal website URL'
          visible true
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
        field :setting_show_email, :boolean do
          label 'Show Email'
          help 'Display your email on the public portfolio'
        end
        field :setting_show_phone, :boolean do
          label 'Show Phone'
          help 'Display your phone number on the public portfolio'
        end
        field :setting_theme_preference, :enum do
          label 'Theme Preference'

          enum do
            [
              ['Light', 'light'],
              ['Dark', 'dark']
            ]
          end

          pretty_value do
            case value
            when 'light' then 'Light'
            when 'dark' then 'Dark'
            else
              value.to_s.humanize
            end
          end

          help 'Choose the default theme for your portfolio'
        end
      end

      group :account do
        label 'Account Settings'
        field :email do
          help 'Your login email address'
        end
        field :password do
          help 'Leave blank to keep current password'
        end
        field :password_confirmation do
          help 'Confirm your new password'
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
      field :name do
        required true
      end
      field :slug do
        read_only true
        help 'Automatically generated from name'
      end
      field :proficiency_level, :enum do
        enum do
          [
            ['Beginner', 'beginner'],
            ['Intermediate', 'intermediate'],
            ['Advanced', 'advanced'],
            ['Expert', 'expert']
          ]
        end

        pretty_value do
          value.to_s.humanize
        end
      end
      field :years_of_experience do
        help 'Years of experience with this skill (e.g., 2.5)'
      end
      field :work_experience_id do
        help 'Optional: Associate with a specific work experience'
      end
    end

    create do
      exclude_fields :slug

      field :name do
        required true
      end
      field :proficiency_level, :enum do
        enum do
          [
            ['Beginner', 'beginner'],
            ['Intermediate', 'intermediate'],
            ['Advanced', 'advanced'],
            ['Expert', 'expert']
          ]
        end

        pretty_value do
          value.to_s.humanize
        end
      end
      field :years_of_experience do
        help 'Years of experience with this skill (e.g., 2.5)'
      end
      field :work_experience_id do
        help 'Optional: Associate with a specific work experience'
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
      exclude_fields :user, :start_date, :end_date, :skills, :project_url, :project_images, :description, :client_name, :client_website, :client_reviews

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
      field :tech_stack do
        help 'Comma-separated list of technologies used'
      end
      field :client_name
      field :client_website
      field :start_date
      field :end_date do
        help 'Leave blank if project is ongoing'
      end

      field :client_reviews do
          help 'Add review from the client reviews tab'
          read_only true
      end
    end

    create do
      exclude_fields :user, :start_date, :end_date, :skills, :project_url, :project_images, :description, :client_name, :client_website, :client_reviews

      field :name do
        required true
      end
      field :role
      field :description, :text do
        required true
      end
      field :tech_stack do
        help 'Comma-separated list of technologies used'
      end
      field :project_url do
        help 'URL to the project (if publicly available)'
      end
      field :client_name
      field :client_website
      field :start_date
      field :end_date do
        help 'Leave blank if project is ongoing'
      end
      field :client_reviews do
        help 'Add review from the client reviews tab'
        read_only true
      end
    end
  end

  # ClientReview configuration
  config.model 'ClientReview' do
    navigation_label 'Portfolio'

    list do
      fields :id, :reviewer_name, :reviewer_company, :rating, :client_project, :created_at

      field :rating do
        pretty_value do
          bindings[:view].rating_badge(value)
        end
      end
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

    list do
      fields :id, :title, :issuer, :credential_url, :issue_date, :expiration_date, :created_at, :updated_at
    end

    edit do
      exclude_fields :user, :credential_url, :issuer

      group :basic do

        label 'Certification Information'
        field :title, :string do
          required true
        end
        field :issuer, :string do
          required true
        end
        field :credential_url, :string do
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
        field :title, :string do
          required true
        end
        field :issuer, :string do
          required true
        end
        field :credential_url, :string do
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

    list do
      fields :school_name, :degree, :field_of_study, :start_year, :end_year
      field :degree_status, :string do
        searchable true
        filterable true
        formatted_value do
          value.to_s.humanize
        end
      end
    end

    edit do
      exclude_fields :user, :school_name, :degree, :degree_status, :field_of_study, :start_year, :end_year, :certificate

      field :school_name do
        required true
      end
      field :degree do
        required true
      end
      field :degree_status, :enum do
        required true
        enum_method :degree_status_enum
      end
      field :field_of_study do
        required true
      end
      field :start_year do
        required true
      end
      field :end_year do
        required true
        help 'Year when education ended or is expected to end'
      end
      field :certificate do
        help 'Upload degree/certificate document'
      end
    end

    create do
      exclude_fields :user, :school_name, :degree, :degree_status, :field_of_study, :start_year, :end_year, :certificate

      field :school_name do
        required true
      end
      field :degree do
        required true
      end
      field :degree_status, :enum do
        required true
        enum_method :degree_status_enum
      end
      field :field_of_study do
        required true
      end
      field :start_year do
        required true
      end
      field :end_year do
        required true
        help 'Year when education ended or is expected to end'
      end
      field :certificate do
        help 'Upload degree/certificate document'
      end
    end
  end

  # Hide ActiveStorage models from navigation
  # File uploads will be handled from respective model pages only
  config.model 'ActiveStorage::Blob' do
    visible false
  end

  config.model 'ActiveStorage::Attachment' do
    visible false
  end
  config.model 'ActiveStorage::VariantRecord' do
    visible false
  end
end


