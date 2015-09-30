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
      login_form_for(@user, options, &block)
    end

    def login_form_for(object, options={}, &block)
      raise "InvalidActingObject" unless object.is_a?(BambooUser::User)

      options = options.merge(url: bamboo_user.login_path(sti_identifier: BambooUser.white_listed_sti_classes.invert[object.class.name]))
      form_for(object, options, &block)
    end

    def signup_form(options={}, &block)
      signup_form_for(@user, options, &block)
    end

    def signup_form_for(object, options={}, &block)
      raise "InvalidActingObject" unless object.is_a?(BambooUser::User)

      options = options.merge(url: bamboo_user.sign_up_path(sti_identifier: BambooUser.white_listed_sti_classes.invert[object.class.name]))
      options = options.merge(multipart: true) if BambooUser.photofy_enabled
      form_for(object, options, &block)
    end

    def invitation_signup_form(options={}, &block)
      invitation_signup_form_for(@user, options, &block)
    end

    def invitation_signup_form_for(object, options={}, &block)
      raise "InvalidActingObject" unless object.is_a?(BambooUser::User)

      options = options.merge(url: bamboo_user.invitation_sign_up_path(sti_identifier: BambooUser.white_listed_sti_classes.invert[object.class.name]))
      form_for(object, options, &block)
    end

    def profile_form(options={}, &block)
      profile_form_for(@user, options, &block)
    end

    def profile_form_for(object, options={}, &block)
      options = options.merge(url: bamboo_user.edit_profile_path(sti_identifier: BambooUser.white_listed_sti_classes.invert[object.class.name]))
      options = options.merge(multipart: true) if BambooUser.photofy_enabled
      form_for(@user, options, &block)
    end

    def reset_password_form(options={}, &block)
      reset_password_form_for(@user, options, &block)
    end

    def reset_password_form_for(object, options={}, &block)
      raise "InvalidActingObject" unless object.is_a?(BambooUser::User)

      options = options.merge(url: bamboo_user.reset_password_path(sti_identifier: BambooUser.white_listed_sti_classes.invert[object.class.name]))
      form_for(object, options, &block)
    end

    def change_password_form(options={}, &block)
      form_for(:user, options.merge(url: bamboo_user.change_password_path), &block)
    end

    def login_snippet(options={})
      _default_options = {
          show_label: true,
          show_forgot_password: true,
          show_remember_me: true,
          show_signup_link: true,
          instructions: true,
          instruction_message: ''
      }
      render(partial: BambooUser.login_partial_path, locals: _default_options.merge(options))
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
          show_extended: true,
          instructions: true,
          instruction_message: ''
      }
      render(partial: BambooUser.signup_partial_path, locals: _default_options.merge(options))
    end

    def invitation_signup_snippet(options={})
      _default_options = {show_label: true}
      render(partial: BambooUser.invitation_signup_partial_path, locals: _default_options.merge(options))
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
          show_extended: true,
          instructions: true,
          instruction_message: 'Please enter your details below.'
      }
      render(partial: BambooUser.user_profile_partial_path, locals: _default_options.merge(options))
    end

    def reset_password_snippet(options={})
      _default_options = {
          show_label: true,
          instructions: true,
          instruction_message: 'Please enter your registered email address below and click “Reset password”. You will receive an email containing instructions and a temporary link for resetting your password.'}
      render(partial: BambooUser.reset_password_partial_path, locals: _default_options.merge(options))
    end

    def change_password_snippet(options={})
      _default_options = {
          show_label: true,
          instructions: true,
          instruction_message: 'Please enter your current password and then new password along with its confirmation for change of password.'}
      render(partial: BambooUser.change_password_partial_path, locals: _default_options.merge(options))
    end

    def linkify(link_path, _url_options = ActionController::Base.default_url_options)
      ActionDispatch::Http::URL.url_for(_url_options.merge(path: link_path))
    end

  end
end
