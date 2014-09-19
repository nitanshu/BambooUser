require_dependency "bamboo_user/application_controller"

module BambooUser
  class SessionsController < ApplicationController
    skip_before_filter :fetch_current_user, only: [:login]

    def login
      if request.post?
        if (user = User.find_by(username: params[:user][:username]).try(:authenticate, params[:user][:password]))
          session[:user] = user.id
          redirect_to (session[:previous_url] || eval(BambooUser.after_login_path)) and return
        end
      end
      render layout: BambooUser.login_screen_layout
    end

    def logout
      session.clear
      redirect_to eval(BambooUser.after_logout_path)
    end
  end
end
