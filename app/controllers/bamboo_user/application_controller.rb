module BambooUser
  #class ApplicationController < ActionController::Base
  class ApplicationController < ::ApplicationController

    attr_accessor :root_owner
    attr_accessor :root_owner_reflection

    before_filter :check_root_owner

    after_signup :default_after_signup
    after_invitation :default_after_invitation
    after_login :default_redirect_after_login
    after_password_reset_request :default_after_password_reset_request
    after_password_reset :default_after_password_reset

    def default_after_signup(user)
      session[:user] = user.id if BambooUser.auto_login_after_signup
      @preserve_previous_url ||= false
      session[:previous_url] = nil unless @preserve_previous_url #Otherwise it may re-take back to sign_up page wrongly, as its path can't be blacklisted as 'hard-coded' way in engine.rb
      #cookies.permanent[:auth_token_p] = @user.auth_token if params[:remember_me]
    end

    def default_after_invitation(options)
      Rails.logger.debug options.inspect
    end

    def default_redirect_after_login(user)
      redirect_to((BambooUser.always_redirect_to_login_path ? eval(BambooUser.after_login_path) : (session[:previous_url] || eval(BambooUser.after_login_path)))) and return false
    end

    def default_after_password_reset_request(options)
      Rails.logger.debug options.inspect
    end

    def default_after_password_reset(user)
      redirect_to(login_path, notice: 'New password created successfully. Please login with updated credentials here.') and return
    end

    def check_root_owner
      if BambooUser.owner_available?
        begin
          if root_element.is_a?(BambooUser.owner_class_name.constantize) and
              (root_element.send(BambooUser.owner_class_reverse_association).class == BambooUser::User::ActiveRecord_Associations_CollectionProxy)
            @root_owner = root_element
            @root_owner_reflection = root_element.send(BambooUser.owner_class_reverse_association)
          end
        rescue Exception => e
          puts <<-eos
            "Add a method or variable named root_element(most probably in ApplicationController) which
            should return an instance of #{BambooUser.owner_class_name}
            which should have a :has_one or :has_many association to #{BambooUser::User.name}"
          eos
          raise e
        end
      end
    end

    def fetch_model_reflection
      @model = if BambooUser.owner_available? #TODO: Need to implement STI over root_element driven user too
                 root_owner_reflection
               elsif params[:sti_identifier].nil?
                 User
               else
                 _class_name = BambooUser.white_listed_sti_classes[params[:sti_identifier]]
                 if _class_name.nil?
                   raise 'InvalidStiClass'
                 else
                   _class = _class_name.constantize
                   if BambooUser::User.descendants.include?(_class)
                     _class
                   else
                     raise 'InvalidStiClass'
                   end
                 end
               end
    end
  end
end
