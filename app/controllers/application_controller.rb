class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Re-authenticate user after updating their own record in Rails Admin (prevents logout)
  after_action :re_authenticate_current_user

  private

  def re_authenticate_current_user
    # Only applies to Rails Admin update actions
    return unless request.path.start_with?('/admin/')
    return unless request.put? || request.patch?
    
    # Check if we just updated a User record (the @object is set by Rails Admin)
    return unless defined?(@object) && @object.is_a?(User)
    
    # Check if it's the current user's record
    return unless current_user && @object.id == current_user.id
    
    # Re-authenticate to prevent logout
    bypass_sign_in(@object)
  end
end
