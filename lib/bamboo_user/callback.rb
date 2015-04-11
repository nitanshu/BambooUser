module BambooUser
  module Callback

    ###### after-invitation_signup callbacks ###########################################
    def after_invitation(*names, &blk)
      @@after_invitation_callbacks ||= []
      @@after_invitation_callbacks << names
      @@after_invitation_callbacks << blk
    end

    def process_after_invitation_callbacks(object, **params)
      @@after_invitation_callbacks ||= []
      @@after_invitation_callbacks.flatten.compact.each do |callback|
        _return = if callback.is_a?(Proc)
                    callback.call(object, params)
                  else
                    object.send(callback, params)
                  end
        return _return if _return == false
      end
    end

  end
end