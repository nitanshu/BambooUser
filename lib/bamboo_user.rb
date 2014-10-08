module BambooUser

  def self.owner_available?
    (not owner_class_name.nil?) and
        (not owner_class_reverse_association.nil?) and
        (owner_class_name.constantize.reflections[owner_class_reverse_association.to_sym].try(:class_name) == 'BambooUser::User')
  end

  def self.after_registration_success_callback(options)
    puts 'This is a stub. Suggestion: Please re-define it to send welcome email or any such other activity'
    puts "options: #{options.inspect}"
    options
  end

  def self.after_password_reset_request_callback(options)
    puts 'This is a stub. Suggestion: Please re-define it to send password reset link email or any such other activity'
    puts "options: #{options.inspect}"
    options
  end

  def self.after_password_reset_confirmed_callback(options)
    puts 'This is a stub. Suggestion: Please re-define it to send password changed confirmation email or any such other activity'
    puts "options: #{options.inspect}"
    options
  end

  mattr_reader :photofy_enabled
  @@photofy_enabled = false

  #Usage example:
  #BambooUser.add_photofy do |user_class|
  # user_class.photofy :collage
  #end
  def self.add_photofy
    raise 'BlockExpected' unless block_given?
    require 'photofy'
    yield(BambooUser::User)
    @@photofy_enabled = true
  end

  mattr_accessor :detail_attributes_to_not_delegate
  @@detail_attributes_to_not_delegate = %w(id id= user_id user_id= created_at updated_at)

  mattr_accessor :owner_class_name
  @@owner_class_name = nil

  mattr_accessor :owner_class_reverse_association
  @@owner_class_reverse_association = nil

  mattr_accessor :login_screen_path
  @@login_screen_path = 'bamboo_user.login_path'

  mattr_accessor :after_login_path
  @@after_login_path = 'main_app.root_path'

  mattr_accessor :after_signup_path
  @@after_signup_path = 'main_app.root_path'

  mattr_accessor :after_logout_path
  @@after_logout_path = 'main_app.root_path'

  mattr_accessor :after_change_password_path
  @@after_change_password_path = 'bamboo_user.my_profile_path'

  mattr_accessor :login_screen_layout
  @@login_screen_layout = 'application'

  mattr_accessor :signup_screen_layout
  @@signup_screen_layout = 'application'

  mattr_reader :all_actions
  @@all_actions = '*'

  mattr_accessor :public_paths
  @@public_paths = {controller_name_1: [all_actions], controller_name_2: [:action_1, :action_2, :action_3]}
end

require "bamboo_user/engine"
