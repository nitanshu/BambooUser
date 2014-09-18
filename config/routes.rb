BambooUser::Engine.routes.draw do
  root 'users#index'

  get 'login' => 'sessions#login', as: 'login'
  post 'login' => 'sessions#login'

  get 'logout' => 'sessions#logout', as: 'logout'

  resources :users
end
