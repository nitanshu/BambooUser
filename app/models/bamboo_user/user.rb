module BambooUser
  class User < ActiveRecord::Base

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

    def request_reset_password!
      BambooUser.after_password_reset_request_callback({
                                                           user: self,
                                                           password_reset_link: BambooUser::Engine.routes.url_helpers.validate_password_reset_path(encoded_params: Base64.urlsafe_encode64("#{self.password_reset_token}||#{self.email}"))
                                                       }) if self.update(password_reset_token: SecureRandom.uuid, password_reset_sent_at: Time.now)
    end

    def request_invitation_signup!
      BambooUser.after_request_invitation_signup_success_callback({
                                                                      user: self,
                                                                      invitation_signup_link: BambooUser::Engine.routes.url_helpers.make_password_to_signup_path(encoded_params: Base64.urlsafe_encode64("#{self.password_reset_token}||#{self.email}"))
                                                                  }) if self.update(password_reset_token: SecureRandom.uuid, password_reset_sent_at: Time.now)
    end

    def perform_reset_password!(user_params, reset_for = 'password_recovery')
      s_user_params = user_params.keep_if { |k, v| %w(password password_confirmation).include?(k) }
      if self.update(s_user_params.merge(password_reset_token: nil, password_reset_sent_at: nil))
        BambooUser.after_registration_success_callback({user: self}) if (reset_for == 'new_signup')
        BambooUser.after_password_reset_confirmed_callback({user: self}) if (reset_for == 'password_recovery')
        return true
      end
      false
    end

    def self.find_or_create_invited_by_email(params={}, send_invitation = true)
      params.stringify_keys!
      raise "EmailRequired" unless  params.include?('email')

      _self = where(email: params['email']).first
      if _self.nil?
        _new_user = new(params.merge(password: "ishouldn'thavebeenthepassword"))
        _new_user.request_invitation_signup! if (_new_user_save_flag = _new_user.save) and send_invitation
        [_new_user, (_new_user_save_flag ? 'created' : 'creation_failed')]
      else
        [_self, 'found']
      end
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