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
          redirect_to(bamboo_user.login_path, notice: 'Login is required. Please login here') unless logged_in? if restrict_access?
        end

        def restrict_access?
          _restrict_access = true
          if BambooUser.public_paths.is_a?(Hash)
            BambooUser.public_paths.stringify_keys!
            if BambooUser.public_paths.keys.include?(params['controller'])
              if BambooUser.public_paths[params['controller']].is_a?(Array)
                _actions = BambooUser.public_paths[params['controller']].collect { |x| x.to_s }
                _restrict_access = false if _actions.include?(BambooUser.all_actions) or _actions.include?(params['action'])
              end
            end
          end
          _restrict_access
        end
      end

      ActionController::Base.send :helper_method, :logged_user
      ActionController::Base.send :before_filter, :fetch_current_user
    end
  end

end
