Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # Disable registration routes - singleton user pattern
  devise_for :users, skip: [:registrations]

  # API routes
  namespace :api do
    namespace :v1 do
      resource :profile, only: [:show], controller: 'profile'
      resources :works, only: [:index]
      resources :client_projects, only: [:index]
      resources :client_reviews, only: [:index]
      resources :company_experiences, only: [:index]
      resources :experience_skills, only: [:index]
      resources :certifications, only: [:index]
      resources :education, only: [:index]
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "rails_admin/main#dashboard"
end
