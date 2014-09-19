require "bamboo_user/engine"

module BambooUser
  mattr_accessor :after_login_path
  mattr_accessor :after_logout_path
  mattr_accessor :login_screen_layout
  mattr_accessor :public_paths

  mattr_reader :all_actions

  @@after_login_path = 'main_app.root_path'
  @@after_logout_path = 'main_app.root_path'
  @@login_screen_layout = 'application'
  @@all_actions = '*'
  @@public_paths = {controller_name_1: [all_actions], controller_name_2: [:action_1, :action_2, :action_3]}
  #@@public_paths = {home: [all_actions], controller_name_2: [:action_1, :action_2, :action_3]}
  #@@public_paths = {controller_name_1: [all_actions], home: [:welcome]}
end
