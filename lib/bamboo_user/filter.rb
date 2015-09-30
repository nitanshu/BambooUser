module BambooUser
  module Filter
    ###### after-login callbacks ###########################################
    def after_login(*names, &blk)
      @@after_login_callbacks ||= []
      @@after_login_callbacks << names
      @@after_login_callbacks << blk
    end

    def process_after_login_callbacks(controller, object)
      @@after_login_callbacks ||= []
      @@after_login_callbacks.flatten.compact.each do |callback|
        _return = if callback.is_a?(Proc)
                    callback.call(object)
                  else
                    controller.send(callback, object)
                  end
        return _return if _return == false
      end
    end

    ###### after-signup callbacks ###########################################
    def after_signup(*names, &blk)
      @@after_signup_callbacks ||= []
      @@after_signup_callbacks << names
      @@after_signup_callbacks << blk
    end

    def process_after_signup_callbacks(controller, object)
      @@after_signup_callbacks ||= []
      @@after_signup_callbacks.flatten.compact.each do |callback|
        _return = if callback.is_a?(Proc)
                    callback.call(object)
                  else
                    controller.send(callback, object)
                  end
        return _return if _return == false
      end
    end

    ###### after-invitation_signup callbacks ###########################################
    def after_invitation(*names, &blk)
      @@after_invitation_callbacks ||= []
      @@after_invitation_callbacks << names
      @@after_invitation_callbacks << blk
    end

    def process_after_invitation_callbacks(controller, **object)
      @@after_invitation_callbacks ||= []
      @@after_invitation_callbacks.flatten.compact.each do |callback|
        _return = if callback.is_a?(Proc)
                    callback.call(object)
                  else
                    controller.send(callback, object)
                  end
        return _return if _return == false
      end
    end

    ###### after-password_reset_request callbacks ######################################
    def after_password_reset_request(*names, &blk)
      @@after_password_reset_request_callbacks ||= []
      @@after_password_reset_request_callbacks << names
      @@after_password_reset_request_callbacks << blk
    end

    def process_after_password_reset_request_callbacks(controller, **object)
      @@after_password_reset_request_callbacks ||= []
      @@after_password_reset_request_callbacks.flatten.compact.each do |callback|
        _return = if callback.is_a?(Proc)
                    callback.call(object)
                  else
                    controller.send(callback, object)
                  end
        return _return if _return == false
      end
    end

    ###### after-password_reset callbacks ######################################
    def after_password_reset(*names, &blk)
      @@after_password_reset_callbacks ||= []
      @@after_password_reset_callbacks << names
      @@after_password_reset_callbacks << blk
    end

    def process_after_password_reset_callbacks(controller, object)
      @@after_password_reset_callbacks ||= []
      @@after_password_reset_callbacks.flatten.compact.each do |callback|
        _return = if callback.is_a?(Proc)
                    callback.call(object)
                  else
                    controller.send(callback, object)
                  end
        return _return if _return == false
      end
    end

  end
end