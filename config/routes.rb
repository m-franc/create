Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Routes pour les profils utilisateurs
  resources :users, only: [:index, :show]

  # General project routes
  root 'projects#index'
  resources :projects do
    resources :notes, only: [:create, :destroy]
  end

  resources :projects do
    resources :documents do
      member do
        get :download
      end
    end
    resources :notes
    resources :tasks
    # Project-specific conversations
    resources :conversations, only: [:index, :new, :create, :show]
  end

  resources :projects


  resources :searches, only: [:index]

  # General conversations
  resources :conversations do
    resources :messages, only: [:create]
    member do
      post 'add_participant'
      delete 'remove_participant'
    end
  end
end
