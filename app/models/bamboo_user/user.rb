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

    def perform_reset_password!(send_email = true)
      if self.update(password_reset_token: SecureRandom.uuid, password_reset_sent_at: Time.now)
        execute_in_thread_in_production do
          UserMailer.password_reset_request_email(self).deliver
        end
      end
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
