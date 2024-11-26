Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check


  # General project routes
  resources :projects do
    # Project-specific conversations
    resource :conversation, only: [:index, :new, :create, :show] do
      resources :messages, only: [:create]
    end
  end

  # General conversations (not tied to projects)
  resources :conversations do
    resources :messages, only: [:create]
  end
end
