require_dependency "bamboo_user/application_controller"

module BambooUser
  class UsersController < ApplicationController

    skip_before_filter :fetch_logged_user, only: [:sign_up, :invitation_sign_up]
    before_filter :fetch_model_reflection, only: [:sign_up, :invitation_sign_up, :edit_profile, :index, :show, :new, :create, :edit, :update, :destroy]
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    def profile
      render layout: BambooUser.profile_screen_layout
    end

    def edit_profile
      @user = logged_user
      if request.patch?
        class_sym = @model.name.underscore.to_sym
        _user_params = user_params(class_sym).clone
        _user_params.delete(:email)
        if @user.update(_user_params)
          redirect_to eval(BambooUser.after_profile_save_path) and return
        else
          logger.info @user.errors.inspect

          #TODO: Its should be "render action: 'xxxx' " instead of redirect because in that case,
          #will loose errors on current acting object while rendering view
          #render action: eval(BambooUser.after_profile_save_failed_path), notice: 'Failed to save' and return
          redirect_to eval(BambooUser.after_profile_save_failed_path), notice: 'Failed to save' and return
        end
      end

      render layout: BambooUser.profile_screen_layout
    end

    def sign_up
      @user = @model.new
      if request.post?
        sti_class = params[:class_type]
        class_sym = @model.name.underscore.to_sym
        @user = if sti_class.nil?
                  @model.new(user_params)
                elsif  BambooUser.valid_sti_class? and (sti_class.constantize < BambooUser::User)
                  session[:previous_url] = nil #Otherwise it may re-take back to reset_password page wrongly, as its path can't be blacklisted as 'hard-coded' way in engine.rb
                  sti_class.constantize.new(user_params(class_sym))
                else
                  raise "InvalidStiClass"
                end
        if @user.save
          session[:user] = @user.id
          #cookies.permanent[:auth_token_p] = user.auth_token if params[:remember_me]

          BambooUser.after_registration_success_callback({user: @user})
          signup_success_handler and return
        else
          signup_failure_handler and return
        end
      end
      render layout: BambooUser.signup_screen_layout
    end

    def invitation_sign_up
      @user = @model.new
      session[:previous_url] = nil #Otherwise it may re-take back to invitation_sign_up page wrongly, as its path can't be blacklisted as 'hard-coded' way in engine.rb
      if request.post?
        class_sym = @model.name.underscore.to_sym
        @user = @model.new(user_params(class_sym).merge(password: "ishouldn'thavebeenthepassword"))

        if @user.save
          @user.request_invitation_signup!

          redirect_to((session[:previous_url] || eval(BambooUser.after_invitation_signup_path)), notice: "An email with signup link has been sent to #{@user.email}. Please check") and return
        else
          logger.info(@user.errors.inspect)
          redirect_to eval(BambooUser.after_invitation_signup_failed_path), notice: 'Invitation failed as user already exist!' and return
        end
      end
      render layout: BambooUser.signup_screen_layout
    end

    def change_password
      if request.post?
        @user = logged_user
        if @user.authenticate(params[:user][:current_password]) and not (params[:user][:password].blank?)
          if @user.update(user_params)
            redirect_to(eval(BambooUser.after_change_password_path), notice: 'Password changed successfully.') and return
          else
            logger.info @user.errors.inspect
            redirect_to(eval(BambooUser.after_change_password_failed_path), notice: 'Invalid new password failed to update.') and return
          end
        else
          redirect_to(eval(BambooUser.after_change_password_failed_path), notice: 'Either current or new password is invalid.') and return
        end
      end
    end

    # GET /users
    def index
      @users = @model.all
    end

    # GET /users/1
    def show
    end

    # GET /users/new
    def new
      @user = @model.new
    end

    # GET /users/1/edit
    def edit
    end

    # POST /users
    def create
      @user = @model.new(user_params)

      if @user.save
        redirect_to @user, notice: 'User was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /users/1
    def update
      if @user.update(user_params)
        redirect_to @user, notice: 'User was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /users/1
    #TODO: If current user is destroyed then session should be invalidated too
    def destroy
      @user.destroy
      redirect_to users_url, notice: 'User was successfully destroyed.'
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = @model.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params(required_class_type = :user)
      params.require(required_class_type).permit(:email, :password, :password_confirmation, :photo, user_detail_attributes: [*UserDetail.columns_hash.keys])
    end
  end
end
