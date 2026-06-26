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

  get "today", to: "today#show"
  get "planner", to: "planner#index"
  get "planner/:date", to: "planner#show", as: :planner_day, constraints: { date: /\d{4}-\d{2}-\d{2}/ }

  resources :plan_items, only: %i[create update destroy] do
    member do
      patch :toggle
    end
  end

  root "shoulds#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
