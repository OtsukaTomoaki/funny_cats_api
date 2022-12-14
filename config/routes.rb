Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get 'auth/:provider/callback', to: 'sessions#create'
  resources :sessions, only: %i[index new create destroy]
  namespace :api, {format: 'json'} do
    namespace :v1 do
      get 'users/profile', to: 'users#profile'
      get 'users/download_avatar_image', to: 'users#download_avatar_image'
      post 'users/create_with_social_accounts', to: 'users#create_with_social_accounts'
      resources :users

      post 'sessions/remember_me', to: 'sessions#remember_me'
      resources :sessions

      resources :user_tags
    end
  end
end
