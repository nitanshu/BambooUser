module BambooUser
  class User < ActiveRecord::Base

    #---Attributes declarations-------------------------------------
    attr_accessor :temp_owner_id

    #---For authentication from bcrypt-ruby-------------------------
    has_secure_password

    #---Associations------------------------------------------------
    has_one :user_detail, dependent: :destroy

    #---Validations ------------------------------------------------
    validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}, uniqueness: true

    #---Nested-Attributes-------------------------------------------
    accepts_nested_attributes_for :user_detail

    #---Callbacks --------------------------------------------------
    after_initialize :provision_user_detail
    before_validation :strip_email
    before_create :generate_auth_token

    if false
      validates :email, length: 2..5
    end

    belongs_to(BambooUser.owner_class_name.to_s.underscore.to_sym, foreign_key: 'owner_id') if BambooUser.owner_available?

    def request_reset_password!
      BambooUser.after_password_reset_request_callback({
                                                           user: self,
                                                           password_reset_link: BambooUser::Engine.routes.url_helpers.validate_password_reset_path(encoded_params: Base64.urlsafe_encode64("#{self.password_reset_token}||#{self.email}"))
                                                       }) if self.update(password_reset_token: SecureRandom.uuid, password_reset_sent_at: Time.now)
    end

    def perform_reset_password!(user_params)
      s_user_params = user_params.keep_if { |k, v| %w(password password_confirmation).include?(k) }
      if self.update(s_user_params.merge(password_reset_token: nil, password_reset_sent_at: nil))
        BambooUser.after_password_reset_confirmed_callback(self)
        return true
      end
      false
    end

    private
    def provision_user_detail
      if user_detail.nil?
        build_user_detail
        user_detail.user = self
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
