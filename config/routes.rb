Rails.application.routes.draw do
  get 'password_resets/create'

  get 'password_resets/edit'

  get 'password_resets/update'

  get 'users/alluser'

  get 'logout' => 'sessions#destroy', :as => 'logout'

  get 'login' => 'donators#login', :as => 'login'

  get 'userlogin' => 'sessions#new', :as => 'userlogin'

  post 'verification' => 'donators#verification', :as => 'verification'

  get 'ordered' => 'donators#ordered', :as => 'ordered'

  root to: 'static_pages#home'

  resources :organizations
  resources :transporters
  resources :donators do
    resources :donations, only: %i[index show new create edit update]
    get 'thank_you', on: :member
  end
  resources :users do
    member do
      get :activate
      patch :confirm
      get :organization_members
    end
  end
  resources :sessions
  resources :donations do
    resources :shares do
      patch 'pickup', on: :member
      get 'thank_you', on: :member
    end
    post 'delivery',          on: :member
    get  'transport',         on: :member
    patch 'confirm_transport', on: :member
    get 'show_donator', on: :member
    patch 'update_transport', on: :member
    get 'thank_you', on: :member
  end
end
