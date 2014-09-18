require_dependency "bamboo_user/application_controller"

module BambooUser
  class SessionsController < ApplicationController
    skip_before_filter :fetch_current_user, only: [:login]

    def login
      if request.post?
        if (user = User.find_by_username(params[:user][:username]))
          session[:user] = user
          redirect_to eval(BambooUser.after_login_path)
        end
      end
    end

    def logout
      session[:user] = nil
      redirect_to eval(BambooUser.after_logout_path)
    end
  end
end
