module BambooUser
  module ApplicationHelper

    def login_form(options={}, &block)
      form_for(:user, options.merge(url: bamboo_user.login_path), &block)
    end

    def reset_password_form(options={}, &block)
      form_for(@user, options.merge(url: bamboo_user.reset_password_path), &block)
    end

    def login_snippet(options={})
      _default_options = {show_label: true, show_forgot_password: true, show_remember_me: true}
      render(partial: 'bamboo_user/sessions/login_form', locals: _default_options.merge(options))
    end

    def reset_password_snippet(options={})
      _default_options = {show_label: true, instructions: true, instruction_message: 'Please enter your registered email address below and click “Reset password”. You will receive an email containing instructions and a temporary link for resetting your password.'}
      render(partial: 'bamboo_user/sessions/reset_password_form', locals: _default_options.merge(options))
    end

  end
end
