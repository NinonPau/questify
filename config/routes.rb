Rails.application.routes.draw do
  get 'user_mood/home'
  root to: "pages#home"
  get "up" => "rails/health#show", as: :rails_health_check
  resources :user_moods, only: [:update, :create, :edit]

end
