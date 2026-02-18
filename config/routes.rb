Rails.application.routes.draw do
  
  devise_for :users
  
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  resources :fellowships, only: [:index, :create, :update, :destroy]

  resources :quests do
    member do # for these actions apply to ONE specific quest.(/quests/:id/invite_ally insteed of /quests/invite_ally) not really sure about it 
      #will change if necessary when we implement the actual invitation flow, 
      #but for now it makes sense to have the quest ID in the URL since we need to know which quest we're inviting an ally to.
      post  :invite_ally
      patch :accept_invitation
      patch :decline_invitation
    end
  end
  # Defines the root path route ("/")
  # root "posts#index"
end
