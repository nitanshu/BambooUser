module BambooUser
  class User < ActiveRecord::Base

    before_validation :strip_username

    has_secure_password

    #validates :username, length: {within: 2..5, if: proc { true }}
    if false
      validates :username, length: 2..5
    end

    private
    def strip_username
      self.username = self.username.to_s.downcase.strip if self.username
    end
  end
end
