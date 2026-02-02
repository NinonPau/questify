Rails.application.routes.draw do
  get 'user_mood/home'
  devise_for :users
  
  root to: "pages#home"
  get "up" => "rails/health#show", as: :rails_health_check
  resources :user_moods, only: [:update, :create, :edit]
  resources :fellowships, only: [:index, :create, :update, :destroy]

end
