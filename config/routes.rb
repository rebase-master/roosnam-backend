Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, skip: [:registrations]

  match '/_next/*path', to: proc { [204, {'Content-Type' => 'text/plain'}, ['']] }, via: :all

  namespace :api do
    namespace :v1 do
      resource :profile, only: [:show], controller: 'profile'
      resource :resume, only: [:show], controller: 'resume'
      resources :client_projects, only: [:index, :show]
      resources :client_reviews, only: [:index]
      resources :work_experiences, only: [:index]
      resources :certifications, only: [:index]
      resources :skills, only: [:index]
      resources :education, only: [:index]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  root "rails_admin/main#dashboard"
end
