require_dependency "bamboo_user/application_controller"

module BambooUser
  class SessionsController < ApplicationController
    skip_before_filter :fetch_logged_user, only: [:login, :reset_password, :validate_password_reset, :make_password]
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
          @user.request_reset_password!
          redirect_to(login_path, notice: 'An email with password reset link has been sent to registered email address. Please check') and return
        else
          flash[:notice] = "No registered user found with email '#{params[:user][:email]}'."
        end
      end
      @user ||= @model.new
      render(layout: BambooUser.signup_screen_layout) if request.get?
    end

    def make_password
      do_password_reset('new_signup')
      render(layout: BambooUser.signup_screen_layout) if request.get?
    end

    def validate_password_reset
      do_password_reset(params[:for]||'password_recovery')
      render(layout: BambooUser.signup_screen_layout) if request.get?
    end

    def do_password_reset(reset_for = 'password_recovery')
      _password_reset_token, @_email = Base64.urlsafe_decode64(params[:encoded_params]).try(:split, '||')
      @user = @model.find_by(email: @_email)
      if request.post?
        if (@user and @user.password_reset_token == _password_reset_token and ((Time.now - @user.password_reset_sent_at) <= 86400.0)) #reset-token shouldn't be more than 1 day(i.e 86400 seconds) old
          if (not params[:user][:password].blank?) and @user.perform_reset_password!(user_params, reset_for)
            session[:previous_url] = nil #Otherwise it may re-take back to reset_password page wrongly, as its path can't be blacklisted as 'hard-coded' way in engine.rb

            if reset_for == 'password_recovery'
              redirect_to(login_path, notice: 'New password created successfully. Please login with updated credentials here.') and return
            elsif reset_for == 'new_signup'
              session[:user] = @user.id
              #cookies.permanent[:auth_token_p] = user.auth_token if params[:remember_me]

              #BambooUser.after_registration_success_callback({user: @user}) #This thing is taken care from @user.perform_reset_password!
              redirect_to((session[:previous_url] || eval(BambooUser.after_signup_path)), notice: 'Welcome') and return
            end
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

    private
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
  end
end
