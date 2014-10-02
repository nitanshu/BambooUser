require_dependency "bamboo_user/application_controller"

module BambooUser
  class UsersController < ApplicationController

    skip_before_filter :fetch_logged_user, only: [:sign_up]
    before_filter :fetch_model_reflection, only: [:sign_up, :index, :show, :new, :create, :edit, :update, :destroy]
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    def sign_up
      @user = @model.new
      if request.post?
        @user = @model.new(user_params)
        if @user.save
          session[:user] = @user.id
          #cookies.permanent[:auth_token_p] = user.auth_token if params[:remember_me]
          redirect_to (session[:previous_url] || eval(BambooUser.after_signup_path)) and return
        end
      end
      render layout: BambooUser.signup_screen_layout
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
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :photo, user_detail_attributes: [])
    end
  end
end
