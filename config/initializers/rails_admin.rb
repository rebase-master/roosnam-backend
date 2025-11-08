RailsAdmin.config do |config|
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
                     :work_experiences, :education, :certifications, :attachments
      
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

  # Hide user_id field in forms for all models with user association
  # and auto-assign to current_user
  config.model 'WorkExperience' do
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


