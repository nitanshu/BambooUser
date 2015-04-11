require 'bamboo_user/callback'
module BambooUser
  class User < ActiveRecord::Base

    #---Extending callbacks ----------------------------------------
    extend BambooUser::Callback

    #---Constants declarations -------------------------------------
    SHOULD_NOT_BE_A_PASSWORD = 'ishouldnothavebeenthepassword'

    #---Attributes declarations-------------------------------------
    attr_accessor :temp_owner_id
    attr_accessor :current_password

    #---For authentication from bcrypt-ruby-------------------------
    has_secure_password

    #---Associations------------------------------------------------
    has_one :user_detail, foreign_key: 'user_id', dependent: :destroy, autosave: true
    belongs_to(BambooUser.owner_class_name.to_s.underscore.to_sym, foreign_key: 'owner_id') if BambooUser.owner_available?

    #---Callbacks --------------------------------------------------
    after_initialize :provision_user_detail
    before_validation :strip_email
    before_create :generate_auth_token

    #---Validations ------------------------------------------------
    validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}, uniqueness: true

    #---Nested attributes acceptance -------------------------------
    accepts_nested_attributes_for :user_detail

    #---Delegations ------------------------------------------------
    delegate *([BambooUser::UserDetail.attribute_names +
                    BambooUser::UserDetail.attribute_names.collect { |x| "#{x}=" }
    ].flatten.compact.delete_if { |x| BambooUser.detail_attributes_to_not_delegate.include?(x) }), to: :user_detail

    #---Class methods ----------------------------------------------
    def self.invitation_sign_up(params, callback_on_success = proc {}, callback_on_failure = proc {}, callback_on_invalid = proc {})
      raise 'InvalidCallbacks' unless (callback_on_success.is_a?(Proc) and callback_on_failure.is_a?(Proc) and callback_on_invalid.is_a?(Proc))

      params.stringify_keys!
      raise 'EmailRequiredInParams' unless  params.include?('email')

      _self = where(email: params['email']).first
      if _self.nil?
        user = new(params.merge(password_reset_token: SecureRandom.uuid,
                                password_reset_sent_at: Time.now,
                                password: SHOULD_NOT_BE_A_PASSWORD))

        if user.save
          _out_inference = {user: user, invitation_path: user.invitation_signup_link, message: 'new_user_created'}
          process_after_invitation_callbacks(user, _out_inference)
          callback_on_success.call(_out_inference)
          return _out_inference
        else
          logger.debug(user.errors.inspect)
          _out_inference = {user: user, errors: user.errors, message: 'errors_on_user_creation'}
          callback_on_failure.call(_out_inference)
          return _out_inference
        end
        return user
      else
        _out_inference = {user: _self, message: 'user_already_exist'}
        process_after_invitation_callbacks(_self, _out_inference)
        callback_on_invalid.call(_out_inference)
        return _out_inference
      end
    end

    #---Instance methods -------------------------------------------
    def reset_password_link(host=nil)
      BambooUser::Engine.routes.url_helpers.send(
          "validate_password_reset_#{host.nil? ? 'path' : 'url'}",
          {
              encoded_params: Base64.urlsafe_encode64("#{self.password_reset_token}||#{self.email}"),
              sti_identifier: BambooUser.white_listed_sti_classes.invert[self.class.name],
              host: host
          })
    end

    def invitation_signup_link(host=nil)
      BambooUser::Engine.routes.url_helpers.send(
          "make_password_to_signup_#{host.nil? ? 'path' : 'url'}",
          {
              encoded_params: Base64.urlsafe_encode64("#{self.password_reset_token}||#{self.email}"),
              sti_identifier: BambooUser.white_listed_sti_classes.invert[self.class.name],
              host: host
          })
    end

    private
    def provision_user_detail
      if self.user_detail.nil?
        build_user_detail
        #self.user_detail.user = self
      end
    end

    def strip_email
      self.email = self.email.to_s.downcase.strip if self.email
    end

    def generate_auth_token
      if self.auth_token.blank?
        begin
          self.auth_token = SecureRandom.urlsafe_base64
        end while User.exists?(:auth_token => self.auth_token)
      end
    end

  end
end