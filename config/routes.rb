BambooUser::Engine.routes.draw do
  root 'users#profile'

  get 'login' => 'sessions#login', as: 'login'
  post 'login' => 'sessions#login'

  get 'logout' => 'sessions#logout', as: 'logout'

  get 'reset-password' => 'sessions#reset_password', as: 'reset_password'
  post 'reset-password' => 'sessions#reset_password'

  get 'validate-password-reset/:encoded_params' => 'sessions#validate_password_reset', as: 'validate_password_reset'
  post 'validate-password-reset/:encoded_params' => 'sessions#validate_password_reset'

  get 'sign-up' => 'users#sign_up', as: 'sign_up'
  post 'sign-up' => 'users#sign_up'

  get 'change-password' => 'users#change_password', as: 'change_password'
  post 'change-password' => 'users#change_password'

  get 'my-profile' => 'users#profile', as: 'my_profile'

  get 'edit-profile' => 'users#edit_profile', as: 'edit_profile'
  patch 'edit-profile' => 'users#edit_profile'

  resources :users
end
