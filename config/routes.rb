Rails.application.routes.draw do
  get "login", to: "sessions#new", as: :login
  delete "logout", to: "sessions#destroy", as: :logout
  get "auth/:provider/callback", to: "sessions#create"
  get "auth/failure", to: "sessions#failure"
  get "auth/token_login", to: "sessions#token_login"

  get "onboarding", to: "onboarding#show", as: :onboarding
  post "onboarding/complete", to: "onboarding#complete", as: :onboarding_complete

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

  get "plan/week", to: "planner_weeks#show", as: :planner_week
  get "plan/week/:date", to: "planner_weeks#show", as: :planner_week_on, constraints: { date: /\d{4}-\d{2}-\d{2}/ }
  get "plan/quarter", to: "planner_quarters#show", as: :planner_quarter
  get "plan/quarter/:year/:q", to: "planner_quarters#show", as: :planner_quarter_on, constraints: { year: /\d{4}/, q: /[1-4]/ }
  get "plan/year", to: "planner_years#show", as: :planner_year
  get "plan/year/:year", to: "planner_years#show", as: :planner_year_on, constraints: { year: /\d{4}/ }

  resources :planner_categories, only: %i[create update destroy]
  resources :planner_items, only: %i[create update destroy] do
    member do
      patch :toggle
    end
  end
  resources :planner_periods, only: %i[update]

  root "today#show"

  get "up" => "rails/health#show", as: :rails_health_check
end
