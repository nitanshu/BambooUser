module BambooUser

  mattr_reader :all_actions
  @@all_actions = '*'

  def self.owner_available?
    (not owner_class_name.nil?) and
        (not owner_class_reverse_association.nil?) and
        (owner_class_name.constantize.reflections[owner_class_reverse_association.to_sym].try(:class_name) == 'BambooUser::User')
  end

  mattr_accessor :owner_class_name
  @@owner_class_name = nil

  mattr_accessor :owner_class_reverse_association
  @@owner_class_reverse_association = nil

  mattr_accessor :after_login_path
  @@after_login_path = 'main_app.root_path'

  mattr_accessor :after_logout_path
  @@after_logout_path = 'main_app.root_path'

  mattr_accessor :login_screen_layout
  @@login_screen_layout = 'application'

  mattr_accessor :public_paths
  @@public_paths = {controller_name_1: [all_actions], controller_name_2: [:action_1, :action_2, :action_3]}
end

require "bamboo_user/engine"
