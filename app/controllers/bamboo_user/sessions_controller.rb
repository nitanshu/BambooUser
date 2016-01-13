require_dependency "bamboo_user/application_controller"

module BambooUser
  class SessionsController < ApplicationController
    skip_before_filter :fetch_logged_user, only: [:login, :reset_password, :validate_password_reset, :make_password]
    before_filter :fetch_model_reflection

    def login
      @user = @model.new
      if request.post?
        class_sym = ((@model == BambooUser::User) ? :user : @model.name.underscore.to_sym)
        if (user = @model.find_by(email: params[class_sym][:email]).try(:authenticate, params[class_sym][:password]))
          session[:user] = user.id
          cookies.permanent[:auth_token_p] = user.auth_token if params[:remember_me]

          return self.class.process_after_login_callbacks(self, user)
        else
          login_failure_handler and return
        end
      end
    end

    def reset_password
      if request.post?
        class_sym = ((@model == BambooUser::User) ? :user : @model.name.underscore.to_sym)

        @user = @model.find_by(email: params[class_sym][:email])
        if (@user)
          if @user.update(password_reset_token: SecureRandom.uuid, password_reset_sent_at: Time.now)
            _return = self.class.process_after_password_reset_request_callbacks(self,
                                                                                user: @user,
                                                                                reset_password_path: @user.reset_password_link,
                                                                                reset_password_url: @user.reset_password_link(request.host_with_port))
            return _return if _return == false

            _notice_message ='An email with password reset link has been sent to registered email address. Please check'
          else
            Rails.logger.debug(@user.errors.inspect)
            _notice_message = 'Some error occurred. Please contact administrator.'
          end
          redirect_to(login_path(sti_identifier: BambooUser.white_listed_sti_classes.invert[@user.class.name]), notice: _notice_message) and return
        else
          flash[:notice] = "No registered user found with email '#{params[class_sym][:email]}'."
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
      class_sym = ((@model == BambooUser::User) ? :user : @model.name.underscore.to_sym)
      @user = @model.find_by(email: @_email)
      if request.post?
        if (@user and @user.password_reset_token == _password_reset_token and ((Time.now - @user.password_reset_sent_at) <= 86400.0)) #reset-token shouldn't be more than 1 day(i.e 86400 seconds) old
          _user_params = user_params(class_sym).clone
          s_user_params = _user_params.keep_if { |k, v| %w(password password_confirmation).include?(k) }

          if (not params[class_sym][:password].blank?) and @user.update(s_user_params.merge(password_reset_token: nil, password_reset_sent_at: nil))
            session[:previous_url] = nil #Otherwise it may re-take back to reset_password page wrongly, as its path can't be blacklisted as 'hard-coded' way in engine.rb

            if reset_for == 'password_recovery'
              _return = self.class.process_after_password_reset_callbacks(self, @user)
              return _return if _return == false

            elsif reset_for == 'new_signup'

              _return = self.class.process_after_signup_callbacks(self, @user)
              return _return if _return == false
              redirect_to (session[:previous_url] || eval(BambooUser.after_signup_path)) and return
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
    def user_params(required_class_type = :user)
      params.require(required_class_type).permit(:email, :password, :password_confirmation)
    end
  end
end
