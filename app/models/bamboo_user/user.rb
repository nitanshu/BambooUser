module BambooUser
  class User < ActiveRecord::Base

    has_secure_password

    before_validation :strip_username
    before_create :generate_auth_token

    #validates :username, length: {within: 2..5, if: proc { true }}
    if false
      validates :username, length: 2..5
    end

    private
    def strip_username
      self.username = self.username.to_s.downcase.strip if self.username
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
