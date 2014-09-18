require "bamboo_user/engine"

module BambooUser
  mattr_accessor :after_login_path
  mattr_accessor :after_logout_path

  @@after_login_path = 'main_app.root_path'
  @@after_logout_path = 'main_app.root_path'
end
