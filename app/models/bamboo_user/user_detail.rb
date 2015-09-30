module BambooUser
  class UserDetail < ActiveRecord::Base

    #---Associations------------------------------------------------
    belongs_to :user

  end
end
