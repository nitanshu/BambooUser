require_dependency "bamboo_user/application_controller"

module BambooUser
  class UsersController < ApplicationController

    before_filter :fetch_model_reflection, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    before_action :set_user, only: [:show, :edit, :update, :destroy]

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
      params.require(:user).permit(:email, :password)
    end
  end
end
