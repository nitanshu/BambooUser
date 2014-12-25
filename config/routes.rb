BambooUser::Engine.routes.draw do
  root 'users#profile'

  get 'login(/:sti_identifier)' => 'sessions#login', as: 'login'
  post 'login(/:sti_identifier)' => 'sessions#login'

  get 'logout' => 'sessions#logout', as: 'logout'

  get 'reset-password(/:sti_identifier)' => 'sessions#reset_password', as: 'reset_password'
  post 'reset-password(/:sti_identifier)' => 'sessions#reset_password'

  get 'validate-password-reset/:encoded_params(/:sti_identifier)' => 'sessions#validate_password_reset', as: 'validate_password_reset'
  post 'validate-password-reset/:encoded_params(/:sti_identifier)' => 'sessions#validate_password_reset'

  get 'sign-up(/:sti_identifier)' => 'users#sign_up', as: 'sign_up'
  post 'sign-up(/:sti_identifier)' => 'users#sign_up'

  get 'invitation-sign-up(/:sti_identifier)' => 'users#invitation_sign_up', as: 'invitation_sign_up'
  post 'invitation-sign-up(/:sti_identifier)' => 'users#invitation_sign_up'

  get 'make-password-to-signup/:encoded_params(/:sti_identifier)' => 'sessions#make_password', as: 'make_password_to_signup'

  get 'change-password(/:sti_identifier)' => 'users#change_password', as: 'change_password'
  post 'change-password(/:sti_identifier)' => 'users#change_password'

  get 'my-profile' => 'users#profile', as: 'my_profile'

  get 'edit-profile(/:sti_identifier)' => 'users#edit_profile', as: 'edit_profile'
  patch 'edit-profile(/:sti_identifier)' => 'users#edit_profile'

  # resources :users
end
