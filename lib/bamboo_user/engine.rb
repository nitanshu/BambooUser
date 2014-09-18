module BambooUser
  class Engine < ::Rails::Engine
    isolate_namespace BambooUser
  end

  class Railtie < ::Rails::Railtie
    initializer "bamboo_users.settings_filters" do
      ActionController::Base.class_eval do

        def logged_user
          @logged_user ||= BambooUser::User.find_by_id(session[:user])
        end

        def logged_in?
          (not logged_user.nil?)
        end

        def fetch_current_user
          redirect_to(bamboo_user.login_path, notice: 'Login is required. Please login here') unless logged_in?
        end

      end

      ActionController::Base.send :before_filter, :fetch_current_user
      ActionController::Base.send :helper_method, :logged_user
    end
  end

end
