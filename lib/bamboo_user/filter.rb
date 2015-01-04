module BambooUser
  module Filter
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
  end
end