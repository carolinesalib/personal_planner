Rails.application.routes.draw do
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
