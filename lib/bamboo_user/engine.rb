require 'action_view/helpers'

module BambooUser
  class Engine < ::Rails::Engine
    isolate_namespace BambooUser
  end

  class Railtie < ::Rails::Railtie
    initializer "bamboo_users.setting_filters" do
      ActionController::Base.send :extend, BambooUser::Filter
    end

    initializer "bamboo_users.settings_filters" do
      ActionController::Base.class_eval do

        def signup_success_handler
          redirect_to (session[:previous_url] || eval(BambooUser.after_signup_path))
        end

        def signup_failure_handler(notice = "Failed to sign up")
          redirect_to eval(BambooUser.after_signup_failed_path), notice: notice
        end

        def logged_user
          @logged_user ||= BambooUser::User.find_by(auth_token: cookies[:auth_token_p]) if cookies[:auth_token_p]
          @logged_user ||= BambooUser::User.find_by(id: session[:user])
          @logged_user
        end

        def logged_in?
          (not logged_user.nil?)
        end

        def fetch_logged_user
          redirect_to(eval(BambooUser.login_screen_path), notice: 'Login is required. Please login here') unless logged_in? if restrict_access?
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

        def restricted_previous_url
          [nil, BambooUser.white_listed_sti_classes.keys].flatten.uniq.collect do |_sti_identifier|
            [
                bamboo_user.login_path(sti_identifier: _sti_identifier),
                bamboo_user.logout_path(sti_identifier: _sti_identifier),
                bamboo_user.reset_password_path(sti_identifier: _sti_identifier),
                bamboo_user.invitation_sign_up_path(sti_identifier: _sti_identifier),
                (BambooUser.custom_signup_path.nil? ? bamboo_user.sign_up_path(sti_identifier: _sti_identifier) : eval(BambooUser.custom_signup_path))
            ]
          end.flatten.uniq.compact
        end

        # Stores last url visited which is needed for post login redirect
        def store_location
          return if request.xhr? or (not request.get?)

          if request.format == "text/html" or request.content_type == "text/html"
            #request.path != "/users/sign_in" &&
            #request.path != "/users/sign_up" &&
            #request.path != "/users/invitation_sign_up" &&
            #request.path != "/users/password/new" &&
            #request.path != "/users/password/edit" &&
            #request.path != "/users/confirmation" &&
            #request.path != "/users/sign_out"
            session[:previous_url] = request.fullpath unless restricted_previous_url.include?(request.path)
          end
        end

        def available_for_non_validated_session
          return true unless logged_in?

          _flag = (([nil, BambooUser.white_listed_sti_classes.keys].flatten.uniq.collect do |_sti_identifier|
            [
                bamboo_user.login_path(sti_identifier: _sti_identifier),
                bamboo_user.reset_password_path(sti_identifier: _sti_identifier),
                bamboo_user.invitation_sign_up_path(sti_identifier: _sti_identifier),
                bamboo_user.sign_up_path(sti_identifier: _sti_identifier),
                (eval(BambooUser.custom_signup_path) unless BambooUser.custom_signup_path.nil?)
            ]
          end) << BambooUser.paths_only_for_non_validated_sessions.collect { |_path| eval(_path) }).flatten.compact.uniq.include?(request.path)

          (redirect_to(eval(BambooUser.revert_back_to_after_hitting_non_validated_sessions_paths)) and return false) if _flag

          true
        end
      end

      ActionController::Base.send :helper_method, :logged_user
      ActionController::Base.send :helper_method, :logged_in?
      ActionController::Base.send :before_filter, :store_location
      ActionController::Base.send :before_filter, :fetch_logged_user
      ActionController::Base.send :before_filter, :available_for_non_validated_session
    end

    initializer "bamboo_users.view_helpers" do
      ActionView::Base.send :include, BambooUser::ApplicationHelper
    end

  end

end
