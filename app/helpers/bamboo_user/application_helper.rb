module BambooUser
  module ApplicationHelper
    def login_snippet(options={})
      _default_options = {show_forgot_password: true, show_remember_me: true}
      render(partial: 'bamboo_user/sessions/login_form', locals: _default_options.merge(options))
    end
  end
end
