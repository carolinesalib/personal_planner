Rails.application.routes.draw do
  get "login", to: "sessions#new", as: :login
  delete "logout", to: "sessions#destroy", as: :logout
  get "auth/:provider/callback", to: "sessions#create"
  get "auth/failure", to: "sessions#failure"

  resource :settings, only: :show do
    patch :toggle_gratitude
  end

  resources :shoulds, only: %i[index create update destroy] do
    member do
      patch :complete
      patch :restore
    end
    collection do
      get :completed
    end
  end

  root "shoulds#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
