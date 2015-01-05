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

    def perform_reset_password!(user_params, reset_for = 'password_recovery')
      s_user_params = user_params.keep_if { |k, v| %w(password password_confirmation).include?(k) }
      if self.update(s_user_params.merge(password_reset_token: nil, password_reset_sent_at: nil))
        BambooUser.after_registration_success_callback({user: self}) if (reset_for == 'new_signup')
        BambooUser.after_password_reset_confirmed_callback({user: self}) if (reset_for == 'password_recovery')
        return true
      end
      false
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