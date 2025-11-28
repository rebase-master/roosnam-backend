class UserProfileSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :display_name, :email, :phone,
             :headline, :bio, :tagline, :location, :timezone,
             :years_of_experience, :current_role, :current_company,
             :availability_status, :hourly_rate,
             :social_links, :profile_photo_url, :resume_url,
             :seo_title, :seo_description, :profile_completeness

  def email
    object.show_email? ? object.email : nil
  end

  def phone
    object.show_phone? ? object.phone : nil
  end

  def current_company
    object.current_company_name
  end

  def profile_photo_url
    return nil unless object.profile_photo.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      object.profile_photo,
      only_path: true
    )
  end

  def resume_url
    return nil unless object.resume.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      object.resume,
      only_path: true
    )
  end
end
