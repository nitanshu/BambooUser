module BambooUser
  class Engine < ::Rails::Engine
    isolate_namespace BambooUser
  end

  class Railtie < ::Rails::Railtie
    initializer "bamboo_users.settings_filters" do
      ActionController::Base.class_eval do

        def fetch_current_user
          redirect_to(bamboo_user.login_path, notice: 'Login is required. Please login here') if session[:user].nil?
        end

      end

      ActionController::Base.send :before_filter, :fetch_current_user
    end
  end

end
