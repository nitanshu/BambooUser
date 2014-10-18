module BambooUser
  module ApplicationHelper

    def column_type_to_field
      {
          'string' => 'text_field',
          'text' => 'text_area',
          'integer' => 'number_field',
          'float' => 'text_field',
          'decimal' => 'text_field',
          'datetime' => 'datetime_field',
          'timestamp' => 'datetime_field',
          'time' => 'time_field',
          'date' => 'date_field',
          'binary' => 'file_field',
          'boolean' => 'check_box'
      }
    end

    def login_form(options={}, &block)
      form_for(:user, options.merge(url: bamboo_user.login_path), &block)
    end

    def signup_form(options={}, &block)
      options = options.merge(url: bamboo_user.sign_up_path)
      options = options.merge(multipart: true) if BambooUser.photofy_enabled
      form_for(@user, options, &block)
    end

    def invitation_signup_form(options={}, &block)
      options = options.merge(url: bamboo_user.invitation_sign_up_path)
      form_for(:user, options, &block)
    end

    def profile_form(options={}, &block)
      options = options.merge(url: bamboo_user.edit_profile_path)
      options = options.merge(multipart: true) if BambooUser.photofy_enabled
      form_for(@user, options, &block)
    end

    def reset_password_form(options={}, &block)
      form_for(@user, options.merge(url: bamboo_user.reset_password_path), &block)
    end

    def change_password_form(options={}, &block)
      form_for(:user, options.merge(url: bamboo_user.change_password_path), &block)
    end

    def login_snippet(options={})
      _default_options = {
          show_label: true,
          show_forgot_password: true,
          show_remember_me: true,
          show_signup_link: true}
      render(partial: 'bamboo_user/sessions/login_form', locals: _default_options.merge(options))
    end

    def signup_snippet
      signup_extended_snippet({show_label: true,
                               show_photo: false,
                               show_extended: false})
    end

    def signup_extended_snippet(options={})
      _default_options = {
          show_label: true,
          show_photo: true,
          show_extended: true}
      render(partial: 'bamboo_user/users/signup_form', locals: _default_options.merge(options))
    end

    def invitation_signup_snippet(options={})
      _default_options = {show_label: true}
      render(partial: 'bamboo_user/users/invitation_signup_form', locals: _default_options.merge(options))
    end

    def profile_edit_snippet
      profile_edit_extended_snippet({show_label: true,
                                     show_photo: false,
                                     show_extended: false})
    end

    def profile_edit_extended_snippet(options={})
      _default_options = {
          show_label: true,
          show_photo: true,
          show_extended: true}
      render(partial: 'bamboo_user/users/profile_form', locals: _default_options.merge(options))
    end

    def reset_password_snippet(options={})
      _default_options = {
          show_label: true,
          instructions: true,
          instruction_message: 'Please enter your registered email address below and click “Reset password”. You will receive an email containing instructions and a temporary link for resetting your password.'}
      render(partial: 'bamboo_user/sessions/reset_password_form', locals: _default_options.merge(options))
    end

    def change_password_snippet(options={})
      _default_options = {
          show_label: true,
          instructions: true,
          instruction_message: 'Please enter your current password and then new password along with its confirmation for change of password.'}
      render(partial: 'bamboo_user/users/change_password_form', locals: _default_options.merge(options))
    end

  end
end
