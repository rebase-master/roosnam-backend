RailsAdmin.config do |config|
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  # Limit access to admins only
  config.authorize_with do
    redirect_to main_app.root_path unless current_user&.respond_to?(:admin?) && current_user.admin?
  end
end


