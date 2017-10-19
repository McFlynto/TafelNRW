Rails.application.routes.draw do
  get 'password_resets/create'

  get 'password_resets/edit'

  get 'password_resets/update'

  get 'users/alluser'

  get 'users/create_password'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'static_pages#home'

  resources :donators
  resources :users
  resources :sessions
end
