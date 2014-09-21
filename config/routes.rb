BambooUser::Engine.routes.draw do
  root 'users#index'

  get 'login' => 'sessions#login', as: 'login'
  post 'login' => 'sessions#login'

  get 'logout' => 'sessions#logout', as: 'logout'

  get 'reset-password' => 'sessions#reset_password', as: 'reset_password'
  post 'reset-password' => 'sessions#reset_password'

  get 'validate-password-reset/:encoded_params' => 'sessions#validate_password_reset', as: 'validate_password_reset'
  post 'validate-password-reset/:encoded_params' => 'sessions#validate_password_reset'

  resources :users
end
