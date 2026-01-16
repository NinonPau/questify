Rails.application.routes.draw do
<<<<<<< HEAD
  get 'user_mood/home'
=======
  devise_for :users
  
>>>>>>> master
  root to: "pages#home"
  get "up" => "rails/health#show", as: :rails_health_check
  resources :user_moods, only: [:update, :create, :edit]

end
