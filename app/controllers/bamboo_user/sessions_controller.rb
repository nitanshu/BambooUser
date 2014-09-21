require_dependency "bamboo_user/application_controller"

module BambooUser
  class SessionsController < ApplicationController
    skip_before_filter :fetch_logged_user, only: [:login, :reset_password, :validate_password_reset]
    before_filter :fetch_model_reflection

    def login
      if request.post?
        if (user = @model.find_by(email: params[:user][:email]).try(:authenticate, params[:user][:password]))
          session[:user] = user.id
          cookies.permanent[:auth_token_p] = user.auth_token if params[:remember_me]
          redirect_to (session[:previous_url] || eval(BambooUser.after_login_path)) and return
        end
      end
      render layout: BambooUser.login_screen_layout
    end

    def reset_password
      if request.post?
        @user = @model.find_by(email: params[:user][:email])
        if (@user)
          @user.perform_reset_password!
          redirect_to(login_path, notice: 'An email with password reset link has been sent to registered email address. Please check') and return
        else
          flash[:notice] = "No registered user found with email '#{params[:user][:email]}'."
        end
      end
      @user ||= @model.new
    end

    def validate_password_reset
      _password_reset_token, @_email = Base64.urlsafe_decode64(params[:encoded_params]).try(:split, '||')
      @user = @model.find_by(email: @_email)
      if request.post?
        if (@user and @user.password_reset_token == _password_reset_token and ((Time.now - @user.password_reset_sent_at) <= 86400.0)) #reset-token shouldn't be more than 1 day(i.e 86400 seconds) old
          if ((not params[:user][:password].blank?)) and
              if @user.update(password: params[:user][:password],
                              password_confirmation: params[:user][:password_confirmation],
                              password_reset_token: nil, password_reset_sent_at: nil)
                session[:previous_url] = nil #Otherwise it may re-take back to reset_password page wrongly, as its pat can't be blacklisted in 'hard-coded' way in engine.rb
                BambooUser.after_password_reset_confirmed_callback(@user)
              end
            redirect_to(login_path, notice: 'New password created successfully. Please login with updated credentials here.') and return
          else
            logger.debug(@user.errors.inspect)
            flash[:notice] = 'Failed to update. Please recheck the password'
          end
        else
          redirect_to(login_path, notice: 'Invalid password reset token in use or it is too old to be used.') and return
        end
      end
    end

    def logout
      session.clear
      cookies.delete(:auth_token_p)
      redirect_to eval(BambooUser.after_logout_path)
    end
  end
end
