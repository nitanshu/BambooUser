module BambooUser
  class User < ActiveRecord::Base

    attr_accessor :temp_owner_id

    has_secure_password

    before_validation :strip_email
    before_create :generate_auth_token

    if false
      validates :email, length: 2..5
    end

    belongs_to(BambooUser.owner_class_name.to_s.underscore.to_sym, foreign_key: 'owner_id') if BambooUser.owner_available?

    def perform_reset_password!
      BambooUser.after_password_reset_request_callback({
                                                     user: self,
                                                     password_reset_link: BambooUser::Engine.routes.url_helpers.validate_password_reset_path(encoded_params: Base64.urlsafe_encode64("#{self.password_reset_token}||#{self.email}"))
                                                 }) if self.update(password_reset_token: SecureRandom.uuid, password_reset_sent_at: Time.now)
    end

    private
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
