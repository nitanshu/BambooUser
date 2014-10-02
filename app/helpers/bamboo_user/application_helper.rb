module BambooUser
  module ApplicationHelper

    def login_form(options={}, &block)
      form_for(:user, options.merge(url: bamboo_user.login_path), &block)
    end

    def signup_form(options={}, &block)
      options = options.merge(url: bamboo_user.sign_up_path)
      options = options.merge(multipart: true) if BambooUser.photofy_enabled
      form_for(@user, options, &block)
    end

    def reset_password_form(options={}, &block)
      form_for(@user, options.merge(url: bamboo_user.reset_password_path), &block)
    end

    def login_snippet(options={})
      _default_options = {
          show_label: true,
          show_forgot_password: true,
          show_remember_me: true,
          show_signup_link: true}
      render(partial: 'bamboo_user/sessions/login_form', locals: _default_options.merge(options))
    end

    def signup_snippet(options={})
      _default_options = {
          show_label: true,
          show_extended: true}
      render(partial: 'bamboo_user/users/signup_form', locals: _default_options.merge(options))
    end

    def reset_password_snippet(options={})
      _default_options = {
          show_label: true,
          instructions: true,
          instruction_message: 'Please enter your registered email address below and click “Reset password”. You will receive an email containing instructions and a temporary link for resetting your password.'}
      render(partial: 'bamboo_user/sessions/reset_password_form', locals: _default_options.merge(options))
    end

  end
end
