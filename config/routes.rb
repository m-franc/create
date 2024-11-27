Rails.application.routes.draw do
  devise_for :users

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # General project routes
  root 'projects#index'
  resources :projects do
    resources :documents do
      member do
        get :download
      end
    end
    resources :notes
    resources :tasks
    # Project-specific conversations
    resource :conversations, only: [:index, :new, :create, :show] do
      resources :messages, only: [:create]
    end
  end

  # General conversations (not tied to projects)
  resources :conversations do
    resources :messages, only: [:create]
  end

end
