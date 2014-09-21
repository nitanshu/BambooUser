module BambooUser
  module ApplicationHelper
    def execute_in_thread_in_production(&block)
      if Rails.env.production?
        Thread.new do
          yield
        end
      else
        yield
      end if block_given?
    end
  end
end
