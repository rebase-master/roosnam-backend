class UserProfileSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :display_name, :email, :phone,
             :headline, :bio, :tagline, :location, :timezone,
             :years_of_experience, :current_role, :current_company,
             :availability_status, :hourly_rate,
             :social_links, :profile_photo_url, :resume_url,
             :seo_title, :seo_description, :profile_completeness

  # Conditionally show email based on settings
  def email
    object.show_email? ? object.email : nil
  end

  # Conditionally show phone based on settings
  def phone
    object.show_phone? ? object.phone : nil
  end

  # Get current company from experiences
  def current_company
    object.current_company_name
  end

  # Profile photo URL from attachments
  def profile_photo_url
    object.profile_photo&.url
  end

  # Resume URL from attachments
  def resume_url
    object.resume&.url
  end
end

